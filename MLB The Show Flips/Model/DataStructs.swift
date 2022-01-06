//
//  DataStructs.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation

struct Page: Decodable {
    let listings: [PlayerListing]
}

struct PlayerListing: Decodable, Identifiable {
    let id = UUID()
    let listing_name: String
    var best_sell_price, best_buy_price: Int
    let item: PlayerItem
    
    private enum CodingKeys: Any, CodingKey {
        case listing_name, best_sell_price, best_buy_price, item
    }
}

struct PlayerItem: Decodable {
    let uuid, name, rarity, team, team_short_name: String
    let img: URL //img url
    let ovr: Int
    let series, display_position: String
    let series_year: Int
}
