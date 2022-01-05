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
    private var currentPage = Criteria.startPage
  private var canLoadMorePages = true
  private var calc = Calculator()

  init() {
    loadMoreContent()
  }

  func loadMoreContentIfNeeded(currentItem item: PlayerListing?) {
    guard let item = item else { //got to a null item, load more data!
      loadMoreContent()
      return
    }

      let thresholdIndex = items.index(items.endIndex, offsetBy: 0) //begin to refresh when you have 3 items until the end
      
    if items.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
      loadMoreContent()
    }
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
          var combinedResult = self.items + responseListings
          combinedResult = self.calc.sortedPlayerListings(listings: &combinedResult, trim: false)
          return combinedResult.reversed()
      })
      .catch({ _ in Just(self.items) })
      .assign(to: &$items)
  }
}
