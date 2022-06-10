//
//  Criteria.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation

class Criteria {
    var minProfit = 1000
    static let initProfit:Int = 1000
    var budget = 30000
    static let initBudget = 30000
    static let startPage = 1
    var excludedSeries:[String] = []
    
    static var shared = Criteria() //singleton
    
    func meetsFlippingCriteria(_ playerModel: inout PlayerDataModel) -> Bool {
        if (playerModel.best_buy_price > self.budget || self.excludedSeries.contains(playerModel.series)) {
            return false
        }
        
        //assign a value for players with no buy orders and thus no buy price
        if (playerModel.best_buy_price == 0 && playerModel.ovr >= 85) {
            playerModel.best_buy_price = 5000
        } else if (playerModel.best_buy_price == 0 && playerModel.ovr < 85 && playerModel.ovr >= 80) {
            playerModel.best_buy_price = 1000
        } else if (playerModel.best_buy_price == 0 && playerModel.ovr < 80 && playerModel.ovr >= 75) {
            playerModel.best_buy_price = 1000
        }
        
        if (playerModel.ovr >= 85 && playerModel.best_buy_price < 5000) { //check for cards listed under
            return false
        } else if (playerModel.ovr >= 80 && playerModel.ovr < 85 && playerModel.best_buy_price < 1000) {
            return false
        }
        
        return true
    }
}
