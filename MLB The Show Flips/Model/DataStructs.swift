//
//  DataStructs.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation

struct Page: Decodable {
    let page: Int
    let total_pages: Int
    let listings: [PlayerListing]
}

struct HistoricalPriceValue: Decodable {
    let date: String //Format: "1/8"
    let best_buy_price, best_sell_price: Int
}

struct CompletedOrder: Decodable {
    let date:String //Format: "1/8/2022 12:51:23 AM"
    let price: String
}

struct MarketListing: Decodable {
    var best_sell_price, best_buy_price: Int
    let item: PlayerItem
    let price_history: [HistoricalPriceValue]
    let completed_orders: [CompletedOrder]
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
