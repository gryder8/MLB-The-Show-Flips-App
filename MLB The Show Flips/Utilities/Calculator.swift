//
//  Calculator.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation
import SwiftUI

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

class Calculator {
    
    /**
     Calculate the profit of flipping the given card, represented by the data model
     */
    func flipProfit(_ playerModel: PlayerDataModel) -> Int {
        let buyActual:Double = Double(playerModel.best_buy_price + 1)
        let sellActual:Double = Double(playerModel.best_sell_price - 1) * 0.9
        return Int(sellActual - buyActual)
    }
    
    func flipProfit(_ bestSellPrice: Int, _ bestBuyPrice: Int) -> Int { //overload
        let buyActual:Double = Double(bestBuyPrice + 1)
        let sellActual:Double = Double(bestSellPrice - 1) * 0.9
        return Int(sellActual - buyActual)
    }
    
    
    private func signFor(_ val: Int) -> String {
        if (val > 0) {
            return "+"
        } else if (val < 0) {
            return "-"
        } else {
            return "" //==0
        }
    }
    
    /**
     Returns a tuple comprising of the title that should be shown for that player and the description for that player
     */
    func playerFlipDescription(_ playerModel: PlayerDataModel) -> (title: String, desc: String) {
        //let playerItem = playerModel.item
        let flipVal = flipProfit(playerModel)
        let nameAndFlipMargin = "\(playerModel.name): \(signFor(flipVal))\(flipVal) "
        let desc = "\(playerModel.ovr) OVR \(playerModel.shortPos), \(playerModel.team), \(playerModel.year): \(playerModel.series)"
        return (nameAndFlipMargin, desc)
    }
    
    /**
     Calculates the transactions per minute given 
     */
    func transactionsPerMinute(completedOrders: [CompletedOrder]) -> Double {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ssa"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let mostRecent: CompletedOrder? = completedOrders.first
        let last: CompletedOrder?  = completedOrders.last
        
        
        
        let firstDate: Date = dateFormatter.date(from: mostRecent!.date) ?? Date()
        let lastDate: Date = dateFormatter.date(from: last!.date) ?? Date().addingTimeInterval(-172800.0) //back 48 hours
        let diffInMinutes = ((firstDate.timeIntervalSinceReferenceDate - lastDate.timeIntervalSinceReferenceDate) / 60).rounded()
        return (Double(completedOrders.count) / diffInMinutes).round(to: 2)
    }
    
    func getPriceHistoriesForGraph(priceHistory: [HistoricalPriceValue]) -> (bestBuy: [Double], bestSell: [Double], dates: [Date]) {
        
//        let year = Calendar.current.component(.year, from: Date())
//
//        let dateFormatter = DateFormatter()
//
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let bestBuy:[Double] = priceHistory.map {entry in Double(entry.best_buy_price)}
        let bestSell: [Double] = priceHistory.map {entry in Double(entry.best_sell_price)}
        let dates: [Date] = priceHistory.map {entry in entry.dateAsDateObject}
        return (bestBuy, bestSell, dates)
    }
    
    func getRates(priceHistory: [HistoricalPriceValue]) -> (buyRate: Int, sellRate: Int) { 
        let newestBuyPrice = priceHistory.first?.best_buy_price ?? 0
        let newestSellPrice = priceHistory.first?.best_sell_price ?? 0
        
        let oldestBuyPrice = priceHistory.last?.best_buy_price ?? 0
        let oldestSellPrice = priceHistory.last?.best_sell_price ?? 0
        
        let buyDiff = newestBuyPrice - oldestBuyPrice
        let sellDiff = newestSellPrice - oldestSellPrice
        
        let buyPct = Int((Double(buyDiff) / Double(max(oldestBuyPrice, 1)))*100) //avoid dividing by 0 using max
        let sellPct = Int((Double(sellDiff) / Double(max(oldestSellPrice, 1)))*100)
        
        return (buyPct, sellPct)
    }
    
}
