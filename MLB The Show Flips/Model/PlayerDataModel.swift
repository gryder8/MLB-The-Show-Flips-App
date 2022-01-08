//
//  ContentDataSource.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/4/22.
//

import Foundation
import Combine
import SwiftUI

class PlayerDataModel: ObservableObject, Equatable, Identifiable {
    
    static func == (lhs: PlayerDataModel, rhs: PlayerDataModel) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    
    @Published var name: String //constructor
    @Published var uuid: String //constructor
    @Published var best_buy_price: Int //constructor
    @Published var best_sell_price: Int //constructor
    @Published var ovr: Int //constructor
    @Published var year: Int //constructor
    @Published var shortPos: String //constructor
    @Published var team: String //constructor
    @Published var series: String //constructor
    @Published var price_history: [HistoricalPriceValue]
    @Published var completed_orders: [CompletedOrder]
    @Published var image: Image
    @Published var imgURL: URL //constructor
    
    let itemURLBaseString:String = "https://mlb21.theshow.com/apis/listing.json?uuid="
    
    init(name: String, uuid: String, bestBuy: Int, bestSell: Int, ovr:Int, year: Int, shortPos: String, team: String, series: String, imgURL: URL) {
        _name = Published.init(initialValue: name)
        _uuid = Published.init(initialValue: uuid)
        _best_buy_price = Published.init(initialValue: bestBuy)
        _best_sell_price = Published.init(initialValue: bestSell)
        _ovr = Published.init(initialValue: ovr)
        _year = Published.init(initialValue: year)
        _shortPos = Published.init(initialValue: shortPos)
        _team = Published.init(initialValue: team)
        _series = Published.init(initialValue: series)
        _price_history = Published.init(initialValue: [])
        _completed_orders = Published.init(initialValue: [])
        _image = Published.init(initialValue: Image(systemName: "photo"))
        _imgURL = Published.init(initialValue: imgURL)
        
    }
    
    public func cacheImage() async {
        let itemURL: URL = URL(string: "\(itemURLBaseString+uuid)")!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: itemURL)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("***Failed to reach API due to status code: \(resp.statusCode)***")
                return
            }
            
            let marketListing: MarketListing = try JSONDecoder().decode(MarketListing.self, from: data)
            
            self.image = await imageFromURL(marketListing.item.img) //update is published
            
            //print("---IMAGE CACHED")
        } catch {
            print("***Failed to cache image with error: \(error.localizedDescription) \n URL used for api call: \(itemURL)")
            self.image = Image(systemName: "person.crop.circle.badge.exclamationmark")
            print("Fell back to default from system")
        }
    }
    
    
    public func cacheMarketTransactionData() async {
        let itemURL: URL = URL(string: "\(itemURLBaseString+uuid)")!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: itemURL)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("***Failed to reach API due to status code: \(resp.statusCode)***")
                return
            }
            
            let marketListing: MarketListing = try JSONDecoder().decode(MarketListing.self, from: data)
            let marketPlayerListing = marketListing
            
            self.best_buy_price = marketPlayerListing.best_buy_price //might as well update these too
            self.best_sell_price = marketPlayerListing.best_sell_price
            
            self.completed_orders = marketListing.completed_orders
            self.price_history = marketListing.price_history
            
            print("---TRANSACTIONS CACHED")
            
        } catch {
            print("***Failed to cache market data with error: \(error.localizedDescription)")
        }
    }
    
    public func cachePlayerListing() async { //update
        //let itemURL: URL = URL(string: "\(itemURLBaseString+uuid)")!
        
        do {
            let (data, response) = try await URLSession.shared.data(from: imgURL)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("***Failed to reach API due to status code: \(resp.statusCode)***")
                return
            }
            
            let marketListing: MarketListing = try JSONDecoder().decode(MarketListing.self, from: data)
            //let marketPlayerListing = marketListing.playerListing
            let marketPlayerItem = marketListing.item
            
            self.best_buy_price = marketListing.best_buy_price //might as well update these too
            self.best_sell_price = marketListing.best_sell_price
            self.ovr = marketPlayerItem.ovr
            self.name = marketPlayerItem.name
            self.series = marketPlayerItem.team
            self.shortPos = marketPlayerItem.display_position
            self.year = marketPlayerItem.series_year
            
            print("---LISTING CACHED")
            
        } catch {
            print("***Failed to cache market data with error: \(error.localizedDescription)")
        }
    }
    
    
    private func imageFromURL(_ url: URL) async -> Image {
        let errorImage = Image(systemName: "person.crop.circle.badge.exclamationmark")
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("***Failed to reach API due to status code: \(resp.statusCode)***")
                return errorImage
            }
            
            let img: UIImage = UIImage(data: data)!
            let ret = Image(uiImage: img)
            //print("---GOT IMAGE FROM URL")
            return ret
        } catch {
            print("***Failed to parse image with exception: \(error.localizedDescription)")
        }
        return errorImage //error
    }
}
    

    
//
//    @discardableResult func loadMoreContentIfNeeded(currentItem item: PlayerListing?) -> Bool { //returns true if more content is needed
//        guard let item = item else { //got to a null item, load more data!
//            loadMoreContent()
//            return true
//        }
//
//        let thresholdIndex = items.index(items.endIndex, offsetBy: -2) //begin to refresh when you have 3 items until the end
//
//        if items.firstIndex(where: { anItem in anItem.id == item.id }) == thresholdIndex {
//            loadMoreContent()
//            return true
//        }
//        return false
//    }
//
//    func refilterItems(with newInst: Criteria) {
//        self.criteria = newInst
//        let calc = Calculator(criteriaInst: newInst)
//        items = items.filter { listing in
//            return calc.flipProfit(listing) >= criteria.minProfit && listing.best_buy_price <= criteria.budget && !criteria.excludedSeries.contains(listing.item.series)
//        }
//    }
//
//
//    private func loadMoreContent() {
//        guard !isLoadingPage && canLoadMorePages else {
//            return
//        }
//
//        //let calc = Calculator()
//        isLoadingPage = true
//
//        let url = URL(string: "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page=\(currentPage)")!
//        URLSession.shared.dataTaskPublisher(for: url)
//            .map(\.data)
//            .decode(type: Page.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .handleEvents(receiveOutput: { response in
//                self.canLoadMorePages = self.currentPage < self.criteria.endPage
//                self.isLoadingPage = false
//                self.currentPage += 1
//            })
//            .map({ response in
//                var responseListings = response.listings
//                responseListings = responseListings.filter { listing in
//                    var mutableListing = listing //make the listing mutable for purposes of calling the meetsCriteria method
//                    let excluded = self.criteria.excludedSeries.contains(listing.item.series)
//                    let valid = self.calc.meetsFlippingCriteria(&mutableListing)
//                    let profitableEnough = self.calc.flipProfit(mutableListing) >= self.criteria.minProfit
//                    return valid && profitableEnough && !excluded
//                }
//                responseListings = self.calc.sortedPlayerListings(listings: &responseListings, trim: false)
//                self.items.append(contentsOf: responseListings)
//                print("Result count: \(self.items.count)")
//                return self.items
//            })
//            .catch({ _ in Just(self.items) })
//                    .assign(to: &$items)
//                    return
//    }
//}
