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
    
    
    var name: String //constructor
    var uuid: String //constructor
    @Published var best_buy_price: Int //constructor
    @Published var best_sell_price: Int //constructor
    var ovr: Int //constructor
    var year: Int //constructor
    var shortPos: String //constructor
    var team: String //constructor
    var series: String //constructor
    @Published var price_history: [HistoricalPriceValue]
    @Published var completed_orders: [CompletedOrder]
    var image: Image
    var imgURL: URL //constructor
    var page: Int
    
    var isFetching = false
    var hasCachedImage = false //flags so we can call fetching from init()
    var hasCachedTransactions = false
    
    let itemURLBaseString:String = "https://mlb22.theshow.com/apis/listing.json?uuid="
    
    let calc = Calculator()
    @Published var transactionsPerMin: Double = 0
    
    init(name: String, uuid: String, bestBuy: Int, bestSell: Int, ovr:Int, year: Int, shortPos: String, team: String, series: String, imgURL: URL, fromPage: Int) {
        self.name = name
        self.uuid = uuid
        _best_buy_price = Published.init(initialValue: bestBuy)
        _best_sell_price = Published.init(initialValue: bestSell)
        self.ovr = ovr
        self.year = year
        self.shortPos = shortPos
        self.team = team
        self.series = series
        _price_history = Published.init(initialValue: [])
        _completed_orders = Published.init(initialValue: [])
        self.image = Image(systemName: "photo")
        self.imgURL = imgURL
        self.page = fromPage
        
    }
    
    @discardableResult
    public func getImageForModel() async -> Image { //NO AWAIT ON NETWORK CALLS HERE (DO NOT BLOCK)
        let itemURL: URL = URL(string: "\(self.imgURL)")!
        
        if (!hasCachedImage) {
            do {
               
                isFetching = true
                let req = URLRequest(url: itemURL)
                //print("Beginning async let for \(name)...")
                async let (data, _) = URLSession.shared.data(for: req)
                
                guard let uiImage = try await UIImage(data: data) else {
                    return Image(systemName: "person.crop.circle.badge.exclamationmark")
                }
                //print("UIImage processed for \(name)...")
                self.image = Image(uiImage: uiImage)
                return Image(uiImage: uiImage)
            } catch {
                print("***Failed to cache image with error: \(error.localizedDescription) \n") //URL used for api call: \(itemURL)")
                self.image = Image(systemName: "person.crop.circle.badge.exclamationmark")
                print("Fell back to default from system")
            }
        } else { //image already cached, just return what we have
            return self.image
        }
        return Image(systemName: "person.crop.circle.badge.exclamationmark") //fall out (error)
    }
    
    func cacheImage(_ image: Image) {
        if (!hasCachedImage) {
            self.image = image
            print("*Image cached for \(self.name)*")
            hasCachedImage = true
        }
    }
    
    
    
    public func getMarketDataForModel() async -> MarketListing {
        let itemURL: URL = URL(string: "\(itemURLBaseString+uuid)")!
        let errorImgURL = URL(string: "https://mlb21.theshow.com/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBczVzIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a63051376496444a959d408eeb385c660d229548/e53423a698b7afe59590c90a70cd448d.jpg")!
        let errorPlayerItem = PlayerItem(uuid: "ERR", name: "Error", rarity: "ERR", team: "ERR", team_short_name: "ERR", img: errorImgURL, ovr: 0, series: "ERROR", display_position: "ex", series_year: 2021)
        let errorMarketListing = MarketListing(best_sell_price: 0, best_buy_price: 0, item: errorPlayerItem, price_history: [], completed_orders: [])
        
        if (!hasCachedTransactions) {
            do {
                isFetching = true
                let req = URLRequest(url: itemURL)
                async let (data, _) = URLSession.shared.data(for: req)
                
                let marketListing: MarketListing = try await JSONDecoder().decode(MarketListing.self, from: data)
                
                return marketListing
  
            } catch {
                print("***Failed to cache market data with error: \(error.localizedDescription)")
            }
        } else {
            let item = PlayerItem(uuid: uuid, name: name, rarity: "", team: self.team, team_short_name: "", img: self.imgURL, ovr: self.ovr, series: self.series, display_position: self.shortPos, series_year: self.year)
            return MarketListing(best_sell_price: best_sell_price, best_buy_price: best_buy_price, item: item, price_history: self.price_history, completed_orders: self.completed_orders)
        }
        return errorMarketListing //error
    }
    
    public func cacheMarketData(_ marketData: MarketListing) {
        //store the date of the last cache and compare it to Date()
        self.best_buy_price = marketData.best_buy_price
        self.best_sell_price = marketData.best_sell_price
        
        self.completed_orders = marketData.completed_orders
        self.price_history = marketData.price_history
//        self.price_history = self.price_history.sorted(by: { entry1, entry2 in return entry1.dateAsDateObject < entry2.dateAsDateObject} )
        
        isFetching = false
        self.transactionsPerMin = calc.transactionsPerMinute(completedOrders: self.completed_orders)
        
        print("Transactions/min: \(self.transactionsPerMin)")
        print("---TRANSACTIONS CACHED for \(marketData.item.name)")
        
        print(self.price_history)
        
        self.hasCachedTransactions = true
    }
    
    
    
    private func imageFromURL(_ url: URL) async -> Image {
        let errorImage = Image(systemName: "person.crop.circle.badge.exclamationmark")
        do {
            isFetching = true
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("***Failed to reach API due to status code: \(resp.statusCode)***")
                return errorImage
            }
            
            let img: UIImage = UIImage(data: data)!
            let ret = Image(uiImage: img)
            //print("---GOT IMAGE FROM URL")
            isFetching = false
            return ret
        } catch {
            print("***Failed to parse image with exception: \(error.localizedDescription)")
        }
        return errorImage //error
    }
}
