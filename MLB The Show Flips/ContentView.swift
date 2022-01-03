//
//  ContentView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder
//

import SwiftUI


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
    let img: String //img url
    let ovr: Int
    let series, display_position: String
    let series_year: Int
}



class ContentViewModel: ObservableObject {
    
    @Published var isFetching = false
    @Published var playerListings = [PlayerListing]()
    
    @Published var errorMessage = ""
    
    
    @MainActor
    func fetchData(pageNum: Int) async {
        let calc = Calculator()
        //let cr = Criteria()
        //for pageNum: Int in startPage...endPage {
        let urlString = "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page=\(pageNum)"
        
        let url = URL(string: urlString)
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url!)
            let page = try JSONDecoder().decode(Page.self, from: data)
            
            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
                print("Failed to reach API due to status code: \(resp.statusCode)")
            }
            
            
            for var listing in page.listings {
                
                if (calc.meetsFlippingCriteria(&listing)) { //add the listing if it's flippable
                    playerListings.append(listing)
                }
            }
            print("\n")
        } catch {
            print("Failed to query API : \(error)")
        }
        //playerListings = calc.sortedPlayerListings(listings: &playerListings, trim: true) //sort the listings
        //}
    }
    
}

class Criteria {
    let minProfit = 5000
    let budget = 45000
    let startPage = 1
    let endPage = 1
    let maxSize = 20
    let excludedSeries:[String] = []
}

class Calculator {
    //["Topps Now"]
    let criteria = Criteria()
    
    func flipProfit(_ player: PlayerListing) -> Int {
        let buyActual:Double = Double(player.best_buy_price + 1)
        let sellActual:Double = Double(player.best_sell_price - 1) * 0.9
        return Int(sellActual - buyActual)
    }
    
    func sortedPlayerListings(listings: inout [PlayerListing], trim: Bool) -> [PlayerListing] { //returns the array of player items sorted by their flip values
        //sorted in place
        listings.sort { (lhs: PlayerListing, rhs: PlayerListing) -> Bool in
            return flipProfit(lhs) < flipProfit(rhs)
        }
        if (trim && listings.count > criteria.maxSize) {
            let range = criteria.maxSize...listings.count-1
            listings.removeSubrange(range)
        }
        return listings
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
    
    func playerFlipDescription(_ playerListing: PlayerListing) -> [String] {
        let playerItem = playerListing.item
        let flipVal = flipProfit(playerListing)
        let nameAndFlipMargin = "\(playerListing.listing_name): +\(flipVal) stubs"
        let desc = "\(playerItem.ovr) OVR \(playerItem.display_position), \(playerItem.team), \(playerItem.series_year): \(playerItem.series)"
        return [nameAndFlipMargin, desc]
    }
    
}

struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}



struct ContentView: View {
    
    @ObservedObject var vm = ContentViewModel()
    let calc = Calculator()
    let criteria = Criteria()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if vm.isFetching {
                    ProgressView()
                        .progressViewStyle(DarkBlueShadowProgressViewStyle())
                        .scaleEffect(1.5, anchor: .center)
                }
                
                VStack {
                    ForEach(vm.playerListings.reversed()) { playerListing in
                        let playerItem = playerListing.item
                        if (calc.flipProfit(playerListing) >= criteria.minProfit) {
                            let url = URL(string: playerItem.img)
                            AsyncImage(url: url) { image in
                                image.fixedSize(horizontal: true, vertical: true)
                                
                            } placeholder: {
                                ProgressView()
                                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
                                    .scaleEffect(1.5, anchor: .center)
                            }
                            VStack {
                                let urlBaseString = "https://mlb21.theshow.com/items/"
                                let text = calc.playerFlipDescription(playerListing).first ?? "Error"
                                let url: URL = URL(string: "\(urlBaseString + playerItem.uuid)")!
                                
                                Link("\(text)", destination: url)
                                    .foregroundColor(.black)
                                    .font(.system(size: 20))
                                Text(calc.playerFlipDescription(playerListing).last ?? "None")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 15))
                            }
                        }
                    }
                }
                
            }
            .navigationTitle("Flipping Cards")
            .task {
                //await vm.fetchData(pageNum: 1)
                for page in criteria.startPage...criteria.endPage {
                    await vm.fetchData(pageNum: page)
                }
                vm.playerListings = calc.sortedPlayerListings(listings: &vm.playerListings, trim: false)
            }
            .navigationBarItems(trailing: refreshButton)
        }
    }
    
    private var refreshButton: some View {
        Button {
            Task.init {
                withAnimation(.easeIn) {
                    vm.playerListings.removeAll()
                }
                
                for page in criteria.startPage...criteria.endPage {
                    await vm.fetchData(pageNum: page)
                }
            }
            
        } label: {
            Text("Refresh")
                .bold()
                .foregroundColor(.teal)
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .background(.gray)
    }
}
