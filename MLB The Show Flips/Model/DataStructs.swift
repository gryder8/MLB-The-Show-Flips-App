//
//  DataStructs.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation
import SwiftUI

/**
 Represents data from one market page
 */
struct Page: Decodable {
    let page: Int
    let total_pages: Int
    let listings: [PlayerListing]
}

/**
 Represents 1 historical price value entry in the price history
 */
struct HistoricalPriceValue: Decodable {
    let date: String //Format: "1/8"
    let best_buy_price, best_sell_price: Int
}

/**
 Represents 1 completed order in the order history
 */
struct CompletedOrder: Decodable {
    let date:String //Format: "1/8/2022 12:51:23 AM"
    let price: String
}

/**
 Represents one listing on the market, with its price history and completed orders
 */
struct MarketListing: Decodable {
    var best_sell_price, best_buy_price: Int
    let item: PlayerItem
    let price_history: [HistoricalPriceValue]
    let completed_orders: [CompletedOrder]
}

/**
 Listing for one player on the market, including the buy and sell price
 */
struct PlayerListing: Decodable, Identifiable {
    var id: String {
        return item.uuid
    }
    let listing_name: String
    var best_sell_price, best_buy_price: Int
    let item: PlayerItem
    
    private enum CodingKeys: Any, CodingKey { //ignore the UUID
        case listing_name, best_sell_price, best_buy_price, item
    }
}

/**
 Struct representing the underlying player item
 */
struct PlayerItem: Decodable {
    let uuid, name, rarity, team, team_short_name: String
    let img: URL //img url
    let ovr: Int
    let series, display_position: String
    let series_year: Int
}
/**
 Represents one roster update, with its date and ID
 */
struct RosterUpdateEntry: Decodable, CustomStringConvertible, Identifiable {
    let id: Int
    let name: String
    var description: String {
        return "\(name), ID: \(id)\n"
    }
}

/**
 Represents an array of RosterUpdateEntry, which is all the roster updates that have been published
 */
struct RosterUpdateHistory: Decodable {
    
    let roster_updates: [RosterUpdateEntry]
}

/**
 Represents an attribute change, with the name and direction and color of the attribute 
 */
struct RosterUpdateAttributeChange: Decodable, CustomStringConvertible, Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    let name, current_value, direction, delta, color: String
    
    var attributeUIColor: Color {
        switch (color) {
            case "yellow": return .yellow
            case "orange": return .orange
            case "blue": return .blue
            default: return .green
        }
    }
    
    var description: String {
        return "Attribute: \(name); VAL: \(current_value), \(delta)\n"
    }
}
/**
 Position change within a roster update
 */
struct RosterUpdatePositionChange: Decodable, CustomStringConvertible, Identifiable {
    let item: PlayerItem
    let name, pos, team, obfuscated_id: String
    
    var id: String {
        return obfuscated_id
    }
    
    var description: String {
        if (team == "Free Agents") {
            return "\(name) is now a free agent"
        }
        return "\(name) is now a \(pos) for the \(team)\n"
    }
}

/**
 Player that has been newly added within a roster update
 */
struct RosterUpdateNewlyAddedPlayer: Decodable, CustomStringConvertible, Identifiable {
    let item: PlayerItem
    let name, team, pos, current_rarity, obfuscated_id: String
    let current_rank: Int
    
    var id: String {
        return obfuscated_id
    }
    
    var description: String {
        return "\(name), \(team): \(current_rank) OVR \(current_rarity) \(pos)\n"
    }
}

/**
 Rating change associated with attribute changes
 */
struct RosterUpdateRatingChange: Decodable, CustomStringConvertible, Identifiable {
    var id: String {
        return obfuscated_id
    }
    
    let name, team, current_rarity, old_rarity, obfuscated_id: String
    let current_rank, old_rank: Int
    var trend_display: Int {
        current_rank - old_rank
    }
    let changes: [RosterUpdateAttributeChange]
    var trend_symbol: String {
        return trend_display > 0 ? "+" : ""
    }
    
    var description: String {
        return "\n\(name), \(team): \(old_rank), \(old_rarity) --> \(current_rank), \(current_rarity) [\(trend_symbol)\(trend_display)]\n \(changes)"
    }
}
/**
 Holds all the changes associatedf with an update
 
 TODO: test/fix position changes and newly added
 */
struct RosterUpdate: Decodable, Identifiable {
    
    var id: UUID {
        return UUID()
    }
    
    let attribute_changes: [RosterUpdateRatingChange]
    //let position_changes: [RosterUpdatePositionChange]
    //let newly_added: [RosterUpdateNewlyAddedPlayer]
}
