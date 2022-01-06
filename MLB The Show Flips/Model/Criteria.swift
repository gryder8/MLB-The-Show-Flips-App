//
//  Criteria.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import Foundation

class Criteria: ObservableObject {
    @Published var minProfit = 5000
    static let initProfit:Int = 5000
    @Published var budget = 45000
    static let initBudget = 45000
    static let startPage = 1
    @Published var endPage = 5
    let maxCardsAtOnce = 30 //should be able to load everything in the page
    @Published var excludedSeries:[String] = []
}
