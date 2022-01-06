//
//  Calculator.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation
import SwiftUI

class Calculator {
    private var criteria: Criteria
    
    init(criteriaInst: Criteria) { //not hierarchical
        self.criteria = criteriaInst
    }
    
    func flipProfit(_ player: PlayerListing) -> Int {
        let buyActual:Double = Double(player.best_buy_price + 1)
        let sellActual:Double = Double(player.best_sell_price - 1) * 0.9
        return Int(sellActual - buyActual)
    }
    
    func sortedPlayerListings(listings: inout [PlayerListing], trim: Bool) -> [PlayerListing] { //returns the array of player items sorted by their flip values
        
        listings.sort { (lhs: PlayerListing, rhs: PlayerListing) -> Bool in
            return flipProfit(lhs) < flipProfit(rhs)
        }
        
        if (trim && listings.count > criteria.maxCardsAtOnce) {
            let range = criteria.maxCardsAtOnce...listings.count-1
            listings.removeSubrange(range)
        }
        return listings.reversed()
    }
    
    private func signFor(_ val: Int) -> String {
        if (val > 0) {
            return "+"
        } else if (val < 0) {
            return "-"
        } else {
            return ""
        }
    }
    
    func meetsFlippingCriteria(_ player: inout PlayerListing) -> Bool {
        let playerItem = player.item
        if (player.best_buy_price > criteria.budget || criteria.excludedSeries.contains(playerItem.series)) {
            return false
        }
        
        //assign a value for players with no buy orders and thus no buy price
        if (player.best_buy_price == 0 && playerItem.ovr >= 85) {
            player.best_buy_price = 5000
        } else if (player.best_buy_price == 0 && playerItem.ovr < 85 && playerItem.ovr >= 80) {
            player.best_buy_price = 1000
        } else if (player.best_buy_price == 0 && playerItem.ovr < 80 && playerItem.ovr >= 75) {
            player.best_buy_price = 1000
        }
        
        if (playerItem.ovr >= 85 && player.best_buy_price < 5000) { //check for cards listed under
            return false
        } else if (playerItem.ovr >= 80 && playerItem.ovr < 85 && player.best_buy_price < 1000) {
            return false
        }
        
        return true
    }
    
    func playerFlipDescription(_ playerListing: PlayerListing) -> (String, String) {
        let playerItem = playerListing.item
        let flipVal = flipProfit(playerListing)
        let nameAndFlipMargin = "\(playerListing.listing_name): \(signFor(flipVal))\(flipVal) "
        let desc = "\(playerItem.ovr) OVR \(playerItem.display_position), \(playerItem.team), \(playerItem.series_year): \(playerItem.series)"
        return (nameAndFlipMargin, desc)
    }
    
}
