//
//  PlayerDataController.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/8/22.
//

import Foundation
import Combine
import SwiftUI



@MainActor //all publishing from here updates the UI and needs to be run on the main thread regardless, so we use @MainActor
class PlayerDataController:ObservableObject {
    
    private var allItems: [String: PlayerDataModel] = [:] //init to empty, stores ALL data
    @Published public var itemsForDisplay: [String: PlayerDataModel] = [:]

    
    var totalPages = 107
    private var lastPageLoaded = 0
    private var pctComplete = 0.0
    private var isFullyLoaded = false
    private var currentSequentialPage = Criteria.startPage
    
    var criteria = Criteria()
    var calc = Calculator()
    @Published var isLoading = true
    
    private let pageBaseURL = "https://mlb22.theshow.com/apis/listings.json?type=mlb_card&page="
    
    func reset() {
        isFullyLoaded = false
        itemsForDisplay.removeAll()
        lastPageLoaded = 0
        pctComplete = 0.0
        currentSequentialPage = Criteria.startPage
        print("Reset to page \(currentSequentialPage)")
    }
    
    func refilterDataForNewCriteria() {
        itemsForDisplay = allItems.filter { item in
            item.value.best_buy_price <= Criteria.shared.budget &&
            calc.flipProfit(item.value) >= Criteria.shared.minProfit &&
            !Criteria.shared.excludedSeries.contains(item.value.series)
        }
    }
    
    /**
     Gets the next page from the API, caching images of each as needed
     */
    func cacheSequentialPage(fromRefresh: Bool = false) async {
        if (fromRefresh) {
            currentSequentialPage = 1
        }
        print("Curr page in sequential cache: \(currentSequentialPage)")
        if (currentSequentialPage > totalPages) {
            return
        }
        
        let pageURL = URL(string: "\(pageBaseURL)\(currentSequentialPage)")!
        
        do {
            isLoading = true
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            
            //print("***Got data, size of \(data)")
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("Failed to reach API due to status code: \(resp.statusCode)")
                return
            }
            
            let page = try JSONDecoder().decode(Page.self, from: data)
            if (totalPages != page.total_pages) { //update if needed
                totalPages = page.total_pages
            }
            
            //use a task group to create a bunch of tasks for fetching the images
            await withTaskGroup(of: Image.self, body: { group in
                let copyOfAllItems = allItems
                for listing in page.listings { //improved performance a little
                    let itm = listing.item
                    var newPlayerDataModel = PlayerDataModel(name: itm.name, uuid: itm.uuid, bestBuy: listing.best_buy_price, bestSell: listing.best_sell_price, ovr: itm.ovr, year: itm.series_year, shortPos: itm.display_position, team: itm.team, series: itm.series, imgURL: itm.img, fromPage: page.page)
                    let myModel = newPlayerDataModel //pointer to the val which we use as basis for call the function within the call group
                    
                    //print("Adding image for \(myModel.name)... [Image cached: \(myModel.hasCachedImage)]")
                    //add the task to get the image to the group
                    group.addTask(priority: .high, operation: {
                        return await myModel.getImageForModel()
                    })
                    
                    
                    if (allItems.keys.contains(newPlayerDataModel.uuid)) { //migrate the old image if we have it (no need to refresh this)
                        if let alreadyStoredItem = copyOfAllItems[newPlayerDataModel.uuid], alreadyStoredItem.hasCachedImage {
                            newPlayerDataModel.image = alreadyStoredItem.image
                            newPlayerDataModel.hasCachedImage = true
                        }
                    }
                    
                    //use async/await
                    for await myImage in group { //synchronous
                        if Task.isCancelled { break }
                        //I'm caching everything, that way if the user changes their criteria we have the images already
                        if (!newPlayerDataModel.hasCachedImage) { // && criteria.meetsFlippingCriteria(&newPlayerDataModel) [for only caching images of valid models]
                            newPlayerDataModel.cacheImage(myImage)
                        }
                        //print("Added image for \(playerDataModel.name)")
                    }
                    
                    //update models if needed (concurrent operation, should be very fast)
                    if (criteria.meetsFlippingCriteria(&newPlayerDataModel)) {
                        itemsForDisplay.updateValue(newPlayerDataModel, forKey: itm.uuid)
                    }
                    
                    allItems.updateValue(newPlayerDataModel, forKey: itm.uuid)
                    
                }
            })
            
            lastPageLoaded = currentSequentialPage
            currentSequentialPage += 1
            pctComplete = Double(lastPageLoaded) / Double(totalPages)
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                print("***DONE LOADING")
            }
        } catch {
            print("***Error caching page: \(error)")
        }

    }
    
   /**
    Sorts the player models from a given page
    */
    func sortedModelsForPage(_ pageNum: Int) {
        var validModelsForPage = getValidPlayersForPage(pageNum)
        return validModelsForPage.sort(by: {calc.flipProfit($0) > calc.flipProfit($1)})
    }
    
    /**
     Gets all the valid models
     */
    func sortedModels() -> [PlayerDataModel] {
        var allValidModels = getValidPlayers()
        allValidModels.sort(by: { itemA, itemB in calc.flipProfit(itemA) > calc.flipProfit(itemB)}) //in place
        return allValidModels
    }
    
    /**
     Removes items gotten from the specified page in the API
     */
    func uncacheForPage(_ invalidationPageNum: Int) {
        allItems = allItems.filter { pair in //removes all values in the dict that don't satisfy this predicate
            pair.value.page != invalidationPageNum
        }
    }
    
    /**
     Clears all!
     */
    func uncacheAll() {
        allItems.removeAll()
        itemsForDisplay.removeAll()
    }
    
    func getValidPlayersForPage(_ pageNum: Int) -> [PlayerDataModel] {
        let allModels:[PlayerDataModel] = allItems.values.filter {value in value.page == pageNum} //get all models from the given page
        let validModels = allModels.filter { player in
            var mutablePlayer = player
            return criteria.meetsFlippingCriteria(&mutablePlayer)
        }
        
        
        return validModels
        
    }
    
    func getValidPlayers() -> [PlayerDataModel] {
        let allModels:[PlayerDataModel] = itemsForDisplay.values.map { $0 } //map the models from the dict (the values) into an array
        return allModels.filter { model in
            return calc.flipProfit(model) >= Criteria.shared.minProfit && model.best_buy_price <= Criteria.shared.budget
        }
    }
    
    func loadMoreContentIfNeeded(model: PlayerDataModel, refresh: Bool = false) {
        let allModelsSorted = sortedModels()
        let count = allModelsSorted.count
        
        
        if (isLoading) {
            return
        }
        
        if (model.uuid == "REFRESH") {
            Task(priority: .high, operation: {
                await cacheSequentialPage(fromRefresh: refresh)
                print("Toggled fetch")
            })
            
            print("Loading more data [refresh triggered]...")
            return
        }
        
        if let idx = allModelsSorted.lastIndex(of: model) {
            if (abs(count - idx) <= 1) {
                print("Loading more data [near bottom of array]...")
                Task.init {
                    await cacheSequentialPage(fromRefresh: refresh)
                    print("Toggled fetch")
                }
            }
        } else { //idx not found (shouldn't be the case)
            print("Loading more data [error!]...")
            Task.init {
                await cacheSequentialPage(fromRefresh: refresh)
                
            }
        }
        
    }
    
    
    ///Returns the player data model for the specified UUID.
    ///If nothing is found, returns nil.
    func getPlayerDataModelForUUID(uuid: String) -> PlayerDataModel {
        return allItems[uuid]!
    }
    
    private func cacheMarketDataForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid] {
            await retrievedModel.getMarketDataForModel()
        }
    }
    
    private func cacheImageForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid] {
            await retrievedModel.getImageForModel()
        }
        
    }
    
    private func cachePlayerListingForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid] {
            await retrievedModel.getMarketDataForModel()
        }
        
    }
    
}
