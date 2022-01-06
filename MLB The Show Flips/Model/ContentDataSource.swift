//
//  ContentDataSource.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/4/22.
//

import Foundation
import SwiftUI
import Combine

class ContentDataSource: ObservableObject {
    
    private var criteria:Criteria
    
    init(criteriaInst: Criteria) { //can't use EnvObj as this is not a hierarchical instance
        self.criteria = criteriaInst
        loadMoreContent()
        calc = Calculator(criteriaInst: criteriaInst)
    }
    
    var calc:Calculator = Calculator(criteriaInst: Criteria())
    
    
    @Published var items = [PlayerListing]()
    @Published var isLoadingPage = false
    public var currentPage = Criteria.startPage
    private var canLoadMorePages = true
    
    
    func setCriteria(new crit:Criteria) {
        self.criteria = crit
    }
    
    
    @discardableResult func loadMoreContentIfNeeded(currentItem item: PlayerListing?) -> Bool { //returns true if more content is needed
        guard let item = item else { //got to a null item, load more data!
            loadMoreContent()
            return true
        }
        
        let thresholdIndex = items.index(items.endIndex, offsetBy: -2) //begin to refresh when you have 3 items until the end
        
        if items.firstIndex(where: { anItem in anItem.id == item.id }) == thresholdIndex {
            loadMoreContent()
            return true
        }
        return false
    }
    
    func refilterItems(with newInst: Criteria) {
        self.criteria = newInst
        let calc = Calculator(criteriaInst: newInst)
        items = items.filter { listing in
            return calc.flipProfit(listing) >= criteria.minProfit && listing.best_buy_price <= criteria.budget && !criteria.excludedSeries.contains(listing.item.series)
        }
    }
    
    
    private func loadMoreContent() {
        guard !isLoadingPage && canLoadMorePages else {
            return
        }
        
        //let calc = Calculator()
        isLoadingPage = true
        
        let url = URL(string: "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page=\(currentPage)")!
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Page.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { response in
                self.canLoadMorePages = self.currentPage < self.criteria.endPage
                self.isLoadingPage = false
                self.currentPage += 1
            })
            .map({ response in
                var responseListings = response.listings
                responseListings = responseListings.filter { listing in
                    var mutableListing = listing //make the listing mutable for purposes of calling the meetsCriteria method
                    let excluded = self.criteria.excludedSeries.contains(listing.item.series)
                    let valid = self.calc.meetsFlippingCriteria(&mutableListing)
                    let profitableEnough = self.calc.flipProfit(mutableListing) >= self.criteria.minProfit
                    return valid && profitableEnough && !excluded
                }
                responseListings = self.calc.sortedPlayerListings(listings: &responseListings, trim: false)
                self.items.append(contentsOf: responseListings)
                print("Result count: \(self.items.count)")
                return self.items
            })
            .catch({ _ in Just(self.items) })
                    .assign(to: &$items)
                    return
    }
}
