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
  @Published var items = [PlayerListing]()
  @Published var isLoadingPage = false
    var currentPage = Criteria.startPage
  private var canLoadMorePages = true
  private var calc = Calculator()

  init() {
    loadMoreContent()
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

 private func loadMoreContent() {
    guard !isLoadingPage && canLoadMorePages else {
      return
    }

    isLoadingPage = true

    let url = URL(string: "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page=\(currentPage)")!
    URLSession.shared.dataTaskPublisher(for: url)
      .map(\.data)
      .decode(type: Page.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .handleEvents(receiveOutput: { response in
        self.canLoadMorePages = self.currentPage < Criteria.endPage
        self.isLoadingPage = false
        self.currentPage += 1
      })
      .map({ response in
          var responseListings = response.listings
          responseListings = responseListings.filter { listing in
              var mutableListing = listing //make the listing mutable for purposes of calling the meetsCriteria method
              return self.calc.meetsFlippingCriteria(&mutableListing) && self.calc.flipProfit(mutableListing) >= Criteria.minProfit
          }
//          var combinedResult = self.items + responseListings
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
