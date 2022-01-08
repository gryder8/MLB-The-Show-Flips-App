//
//  PlayerDataController.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/8/22.
//

import Foundation
import Combine


//TODO: Integrate controls with new code, using ObservedObject
//  -for the criteria, pass it down as an observed object and call a method to reset the data by setting the cards for display as a sub-dict of AllItems
class PlayerDataController:ObservableObject {
    
    private var allItems: [String: (model: PlayerDataModel, pageNum: Int)] = [:] //init to empty, stores ALL data
    //private var pagedAllItems: [Int: PlayerDataModel] = [:] //to get all items on a page, flatten to array using compact map
    @Published private var itemsForDisplay: [String: PlayerDataModel] = [:]
    
    var totalPages = 107
    private var lastPageLoaded = 0
    private var pctComplete = 0.0
    private var isFullyLoaded = false
    private var currentSequentialPage = Criteria.startPage
    
    var criteria = Criteria()
    var calc = Calculator()
    var isLoading = true
    
    private let pageBaseURL = "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page="
    
    func reset() {
        isFullyLoaded = false
        allItems.removeAll()
        itemsForDisplay.removeAll()
        lastPageLoaded = 0
        currentSequentialPage = Criteria.startPage
    }
    
    
    func cachePage(_ pageNum: Int) async {
        let pageURL = URL(string: "\(pageBaseURL)\(pageNum)")!
        
        do {
            isLoading = true
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("Failed to reach API due to status code: \(resp.statusCode)")
                return
            }
            
            let page = try JSONDecoder().decode(Page.self, from: data)
            
            if (totalPages != page.total_pages) { //update if needed
                totalPages = page.total_pages
            }
            
            for listing in page.listings {
                let itm = listing.item
                var playerDataModel = PlayerDataModel(name: itm.name, uuid: itm.uuid, bestBuy: listing.best_buy_price, bestSell: listing.best_sell_price, ovr: itm.ovr, year: itm.series_year, shortPos: itm.display_position, team: itm.team, series: itm.series, imgURL: itm.img)
                await playerDataModel.cacheImage()
                
                if (criteria.meetsFlippingCriteria(&playerDataModel)) {
                    itemsForDisplay.updateValue(playerDataModel, forKey: itm.uuid)
                }
                
                allItems.updateValue((playerDataModel, page.page), forKey: itm.uuid)
                //pagedAllItems.updateValue(playerDataModel, forKey: page.page)
            }
            
            lastPageLoaded = page.page
            pctComplete = Double(lastPageLoaded) / Double(totalPages)
            isLoading = false
            
        } catch {
            print("***Error caching page: \(error.localizedDescription)")
        }
    }
    
    func cacheSequentialPage() async {
        if (currentSequentialPage >= totalPages) {
            return
        }
        
        let pageURL = URL(string: "\(pageBaseURL)\(currentSequentialPage)")!
        
        do {
            isLoading = true
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            
            print("***Got data, size of \(data)")
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("Failed to reach API due to status code: \(resp.statusCode)")
                return
            }
            
            let page = try JSONDecoder().decode(Page.self, from: data)
            
            if (totalPages != page.total_pages) { //update if needed
                totalPages = page.total_pages
            }
            
            for listing in page.listings {
                let itm = listing.item
                var playerDataModel = PlayerDataModel(name: itm.name, uuid: itm.uuid, bestBuy: listing.best_buy_price, bestSell: listing.best_sell_price, ovr: itm.ovr, year: itm.series_year, shortPos: itm.display_position, team: itm.team, series: itm.series, imgURL: itm.img)
                await playerDataModel.cacheImage()
                
                if (criteria.meetsFlippingCriteria(&playerDataModel)) {
                    itemsForDisplay.updateValue(playerDataModel, forKey: itm.uuid)
                }
                
                allItems.updateValue((playerDataModel, page.page), forKey: itm.uuid)
                
                //pagedAllItems.updateValue(playerDataModel, forKey: page.page)
            }
            
            print("Updated allItems, new count is \(allItems.count)")
            
            lastPageLoaded = currentSequentialPage
            currentSequentialPage += 1
            pctComplete = Double(lastPageLoaded) / Double(totalPages)
            isLoading = false
            
        } catch {
            print("***Error caching page: \(error.localizedDescription)")
        }
    }
    
    
    func cacheNextPage() async {
        if (lastPageLoaded == totalPages) {
            return
        }
        
        let pageNum = lastPageLoaded+1
        let pageURL = URL(string: "\(pageBaseURL)\(pageNum)")!
        
        do {
            isLoading = true
            let (data, response) = try await URLSession.shared.data(from: pageURL)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("**Failed to reach API due to status code: \(resp.statusCode)")
                return
            }
            
            let page = try JSONDecoder().decode(Page.self, from: data)
            
            totalPages = page.total_pages
            
            for listing in page.listings {
                let itm = listing.item
                var playerDataModel = PlayerDataModel(name: itm.name, uuid: itm.uuid, bestBuy: listing.best_buy_price, bestSell: listing.best_sell_price, ovr: itm.ovr, year: itm.series_year, shortPos: itm.display_position, team: itm.team, series: itm.series, imgURL: itm.img)
                await playerDataModel.cacheImage() //cache the image of the model when we create it
                
                if (criteria.meetsFlippingCriteria(&playerDataModel)) {
                    itemsForDisplay.updateValue(playerDataModel, forKey: itm.uuid)
                }
                
                allItems.updateValue((playerDataModel, page.page), forKey: itm.uuid)
                //pagedAllItems.updateValue(playerDataModel, forKey: page.page)
            }
            
            
            lastPageLoaded = page.page
            pctComplete = Double(lastPageLoaded) / Double(totalPages)
            isLoading = false
        } catch {
            print("***Error caching page: \(error.localizedDescription)")
        }
    }
    
    func sortedModelsForPage(_ pageNum: Int) {
        var validModelsForPage = getValidPlayersForPage(pageNum)
        return validModelsForPage.sort(by: {calc.flipProfit($0) > calc.flipProfit($1)})
    }
    
    func sortedModels() -> [PlayerDataModel] {
        var allValidModels = getValidPlayers()
        allValidModels.sort(by: {calc.flipProfit($0) > calc.flipProfit($1)}) //in place
        if (!allItems.isEmpty) {
            print("Returned \(allValidModels.count) cards. \(((Double(allValidModels.count) / Double(allItems.count)) * 100.0).rounded())% of cards were returned")
        }
        return allValidModels
    }
    
    func uncacheForPage(_ invalidationPageNum: Int) {
        allItems = allItems.filter { pair in //removes all values in the dict that don't satisfy this predicate
            pair.value.pageNum != invalidationPageNum
        }
    }
    
    func uncacheAll() {
        allItems.removeAll()
    }
    
    func getValidPlayersForPage(_ pageNum: Int) -> [PlayerDataModel] {
        let allModels:[PlayerDataModel] = allItems.values.filter {tuple in tuple.pageNum == pageNum}.map {validTuples in validTuples.model } //create a collection from the dict values where all the items are tuples where the int matches the page num, then map the models from the tuples into an array of data model
        let validModels = allModels.filter { player in
            var mutablePlayer = player
            return criteria.meetsFlippingCriteria(&mutablePlayer)
        }
        
        
        return validModels
        
    }
    
    func getValidPlayers() -> [PlayerDataModel] {
        let allModels:[PlayerDataModel] = itemsForDisplay.values.map { $0 }
        return allModels.filter { model in
            return calc.flipProfit(model) >= Criteria.shared.minProfit && model.best_buy_price <= Criteria.shared.budget
        }
    }
    
    func loadMoreContentIfNeeded(model: PlayerDataModel) {
        let allModelsSorted = sortedModels()
        let count = allModelsSorted.count
        
        if (isLoading) {
            return
        }
        
        if (model.uuid == "NIL") {
            Task.init {
                await cacheSequentialPage()
            }
            print("Loading more data [nil fallout]...")
            return
        }
        
        if let idx = allModelsSorted.lastIndex(of: model) {
            if (abs(count - idx) <= 1) {
                print("Loading more data [near bottom of array]...")
                Task.init {
                    await cacheSequentialPage()
                }
            }
        } else { //idx not found (shouldn't be the case)
            print("Loading more data [error!]...")
            Task.init {
                await cacheSequentialPage()
                
            }
        }
        
    }
    
    
    ///Returns the player data model for the specified UUID.
    ///If nothing is found, returns nil.
    func getPlayerDataModelForUUID(uuid: String) -> PlayerDataModel {
        return allItems[uuid]!.model
    }
    
    private func cacheMarketDataForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid]?.model {
            await retrievedModel.cacheMarketTransactionData()
        }
    }
    
    private func cacheImageForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid]?.model {
            await retrievedModel.cacheImage()
        }
        
    }
    
    private func cachePlayerListingForModelAtUUID(_ uuid: String) async {
        if let retrievedModel = allItems[uuid]?.model {
            await retrievedModel.cacheMarketTransactionData()
        }
        
    }
    
}

