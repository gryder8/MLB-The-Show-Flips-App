//
//  Calculator.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation
import SwiftUI

class Calculator {
//    private var criteria: Criteria
//
//    init(criteriaInst: Criteria) { //not hierarchical
//        self.criteria = criteriaInst
//    }
    
    func flipProfit(_ playerModel: PlayerDataModel) -> Int {
        let buyActual:Double = Double(playerModel.best_buy_price + 1)
        let sellActual:Double = Double(playerModel.best_sell_price - 1) * 0.9
        return Int(sellActual - buyActual)
    }
    
    
//    func sortedPlayerListings(listings: inout [PlayerDataModel]) -> [PlayerDataModel] { //returns the array of player items sorted by their flip values
//        
//        listings.sort { (lhs: PlayerDataModel, rhs: PlayerDataModel) -> Bool in
//            return flipProfit(lhs) < flipProfit(rhs)
//        }
//        
//        return listings.reversed()
//    }
    
    private func signFor(_ val: Int) -> String {
        if (val > 0) {
            return "+"
        } else if (val < 0) {
            return "-"
        } else {
            return ""
        }
    }
    
//    func meetsFlippingCriteria(_ player: inout PlayerListing) -> Bool {
//        let playerItem = player.item
//        if (player.best_buy_price > criteria.budget || criteria.excludedSeries.contains(playerItem.series)) {
//            return false
//        }
//
//        //assign a value for players with no buy orders and thus no buy price
//        if (player.best_buy_price == 0 && playerItem.ovr >= 85) {
//            player.best_buy_price = 5000
//        } else if (player.best_buy_price == 0 && playerItem.ovr < 85 && playerItem.ovr >= 80) {
//            player.best_buy_price = 1000
//        } else if (player.best_buy_price == 0 && playerItem.ovr < 80 && playerItem.ovr >= 75) {
//            player.best_buy_price = 1000
//        }
//
//        if (playerItem.ovr >= 85 && player.best_buy_price < 5000) { //check for cards listed under
//            return false
//        } else if (playerItem.ovr >= 80 && playerItem.ovr < 85 && player.best_buy_price < 1000) {
//            return false
//        }
//
//        return true
//    }
    
    func playerFlipDescription(_ playerModel: PlayerDataModel) -> (title: String, desc: String) {
        //let playerItem = playerModel.item
        let flipVal = flipProfit(playerModel)
        let nameAndFlipMargin = "\(playerModel.name): \(signFor(flipVal))\(flipVal) "
        let desc = "\(playerModel.ovr) OVR \(playerModel.shortPos), \(playerModel.team), \(playerModel.year): \(playerModel.series)"
        return (nameAndFlipMargin, desc)
    }
    
}
