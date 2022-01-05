//
//  ContentView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder
//

import SwiftUI

//FIX: Duplicate entries on entering new min profit in settings screen

class ContentViewModel: ObservableObject {
    
    @Published var isFetching = false
    @Published var playerListings = [PlayerListing]()
    
    @Published var errorMessage = ""
    
    
//    @MainActor
//    func fetchData(pageNum: Int) async {
//        let calc = Calculator()
//        //let cr = Criteria()
//        //for pageNum: Int in startPage...endPage {
//        let urlString = "https://mlb21.theshow.com/apis/listings.json?type=mlb_card&page=\(pageNum)"
//
//        let url = URL(string: urlString)
//
//        do {
//            let (data, response) = try await URLSession.shared.data(from: url!)
//            let page = try JSONDecoder().decode(Page.self, from: data)
//
//            if let resp = response as? HTTPURLResponse, resp.statusCode >= 300 {
//                print("Failed to reach API due to status code: \(resp.statusCode)")
//            }
//
//
//            for var listing in page.listings {
//
//                if (calc.meetsFlippingCriteria(&listing)) { //add the listing if it's flippable
//                    playerListings.append(listing)
//                }
//            }
//            print("\n")
//        } catch {
//            print("Failed to query API : \(error)")
//        }
//        //playerListings = calc.sortedPlayerListings(listings: &playerListings, trim: true) //sort the listings
//        //}
//    }
//
}



struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

struct MainListContentRow: View {
    var playerListing:PlayerListing
    var playerItem:PlayerItem
    let calc = Calculator()
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    init (playerListing: PlayerListing, playerItem: PlayerItem) {
        self.playerListing = playerListing
        self.playerItem = playerItem
    }
    
    var body: some View {
        
        VStack {
            AsyncImage(url: playerItem.img, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                            case .empty:
                                ProgressView()
                                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
                                    .scaleEffect(1.5, anchor: .center)
                            case .success(let image):
                                image
                                    .fixedSize(horizontal: true, vertical: true)
                            case .failure:
                                Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .scaleEffect(3.5)
                            .padding(.bottom, 10)
                            .foregroundColor(.red)
                            @unknown default:
                                EmptyView()
                        }
            }
//            AsyncImage(url: playerItem.img) { image in
//                image.fixedSize(horizontal: true, vertical: true)
//
//
//            } placeholder: {
//                ProgressView()
//                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
//                    .scaleEffect(1.5, anchor: .center)
//            }
            
            let text = calc.playerFlipDescription(playerListing).0
            let url: URL = URL(string: "\(urlBaseString + playerItem.uuid)")!
            HStack (spacing: 0){
                Link("\(text)", destination: url)
                    .foregroundColor(.black)
                    .font(.system(size: 22))
                
                Image("stubs")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20, alignment: .center)
            }.transition(.slide.animation(.easeInOut))
            Text(calc.playerFlipDescription(playerListing).1)
                .foregroundColor(Colors.darkGray)
                .font(.system(size: 16))
        }.transition(.opacity.combined(with: .scale.animation(.easeInOut(duration: 0.3))))
    }
}

//struct CustomDivider: View {
//    let color: Color = .black
//    let width: CGFloat = 1.3
//    var body: some View {
//        Rectangle()
//            .fill(color)
//            .frame(height: width)
//            .edgesIgnoringSafeArea(.horizontal)
//    }
//}


struct ContentView: View {
    
    init() {
        // this is not the same as manipulating the proxy directly
        let standardAppearance = UINavigationBarAppearance()
        
        // this overrides everything you have set up earlier.
        standardAppearance.configureWithTransparentBackground()
        let scrollingAppearance = standardAppearance
        scrollingAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.clear
        ]
        
        
        
        // this only applies to big titles
        //        standardAppearance.largeTitleTextAttributes = [
        //            .font : Font.system(size: 30, weight: .bold, design: .rounded),
        //            NSAttributedString.Key.foregroundColor : UIColor.black
        //        ]
        // this only applies to small titles
        //        appearance.titleTextAttributes = [
        //            .font : UIFont.systemFont(ofSize: 20),
        //            NSAttributedString.Key.foregroundColor : UIColor.black
        //        ]
        
        //In the following two lines you make sure that you apply the style for good
        UINavigationBar.appearance().scrollEdgeAppearance = scrollingAppearance
        UINavigationBar.appearance().standardAppearance = standardAppearance
        
        // This property is not present on the UINavigationBarAppearance
        // object for some reason and you have to leave it til the end
        UINavigationBar.appearance().tintColor = .black
        
    }
    
    
    //@ObservedObject var viewModel = ContentViewModel()
    //@GestureState var dragAmount = CGSize.zero
    //@State var hidesNavBar = false
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    let calc = Calculator()
    let criteria = Criteria()
    @ObservedObject var dataSource = ContentDataSource()
    
    var loadedPage: Int = Criteria.startPage

    
    var body: some View {
        
        NavigationView {
            LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay(
                    ScrollView {
                        LazyVStack {
                            ForEach(dataSource.items) { playerListing in
                                let playerItem = playerListing.item
                                MainListContentRow(playerListing: playerListing, playerItem: playerItem)
                                    .onAppear {
                                        dataSource.loadMoreContentIfNeeded(currentItem: playerListing)
                                        
                                    }
                                    .padding(.all, 30)
                            }
                            
                            if dataSource.isLoadingPage {
                                ProgressView()
                                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
                                    .scaleEffect(1.5, anchor: .center)
                            }
                            
                        }
                        
                    }
                )
                .navigationTitle("Best Flips")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        refreshButton
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Click a card name to open on the web")
                            .italic()
                            .font(.system(size: 14))
                            .lineLimit(1)
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        settingsButton
                    }
                }
        }
    }
    
        private var refreshButton: some View {
            Button {
                dataSource.items.removeAll()
                dataSource.currentPage = Criteria.startPage
                dataSource.loadMoreContentIfNeeded(currentItem: nil)
            } label: {
                Label("Refresh", systemImage: "arrow.triangle.2.circlepath.circle")
                    .scaleEffect(1.5)
                    .foregroundColor(.black)
            }
        }
    
    private var settingsButton: some View {
        NavigationLink(destination: CriteriaController()) {
            Image(systemName: "gearshape")
                .foregroundColor(.black)
                .scaleEffect(1.5)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .background(.gray)
            .previewInterfaceOrientation(.portrait)
    }
}
