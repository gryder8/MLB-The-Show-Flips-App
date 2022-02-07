//
//  ContentView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder
//

import SwiftUI

//TODO: Add local data storage and test filters a little more

class ContentViewModel: ObservableObject {
    
    @Published var isFetching = false
    @Published var playerListings = [PlayerListing]()
    
    @Published var errorMessage = ""
}



struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

//let playerDataController = PlayerDataController()
let REFRESH_MODEL:PlayerDataModel = PlayerDataModel(name: "", uuid: "REFRESH", bestBuy: 0, bestSell: 0, ovr: 0, year: 0, shortPos: "", team: "", series: "", imgURL: URL(string:"https://apple.com")!, fromPage: 0)


struct MainListContentRow: View {
    
    @ObservedObject var playerModel: PlayerDataModel
    //    var playerListing: PlayerListing
    //    var playerItem:PlayerItem
    
    var gradColors: [Color]
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    init (model: PlayerDataModel, gradColors: [Color]) {
        self.gradColors = gradColors
        _playerModel = ObservedObject.init(initialValue: model)
    }
    
    var body: some View {
        let calc = Calculator()
        VStack {
//            playerModel.image
//                .onAppear(perform: {
//                    if (playerModel.image == Image(systemName: "photo")) { //if it appears with a defaulted image, go spin a thread to load the correct one
//                        Task.init {
//                            await playerModel.getImageForModel()
//                        }
//                    }
//                })
//
            let text = calc.playerFlipDescription(playerModel).title
            //let url: URL = URL(string: "\(urlBaseString + playerModel.uuid)")!
            HStack (spacing: 0){
                NavigationLink("\(text)", destination: CardDetailView(playerModel: playerModel, gradColors: self.gradColors))
                    .simultaneousGesture(TapGesture().onEnded({
                        Task.init {
                            async let marketData =  playerModel.getMarketDataForModel()
                            await playerModel.cacheMarketDate(marketData)
                        }
                    }))
                    .foregroundColor(.black)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                StubSymbol()
            }.transition(.slide.animation(.easeInOut))
            Text(calc.playerFlipDescription(playerModel).desc)
                .foregroundColor(Colors.darkGray)
                .font(.system(size: 20, design: .rounded))
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

//struct Universals: ViewModifier {
//    static var criteria = Criteria()
//    static var firstLoad = true
//
//    func body(content: Content) -> some View {
//        content
//            .environmentObject(Self.criteria)
//    }
//}

//@MainActor
struct ContentView: View {
    
    public static var hasInitialized = false
    
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
    
    
    //@GestureState var dragAmount = CGSize.zero
    //@State var hidesNavBar = false
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    
    //@StateObject var criteria = Universals.criteria
    @State var gradientColors = Colors.backgroundGradientColors
    
    
    @StateObject var playerDataController: PlayerDataController = PlayerDataController() //initialization replaced
    
    var loadedPage: Int = Criteria.startPage
    
    var body: some View {
        NavigationView {
            LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay(
                    ScrollView {
                        ScrollViewReader { value in
                            VStack {
                                HStack(spacing: 3) {
                                    Text("Budget Per Card: \(Criteria.shared.budget)")
                                        .padding(.vertical, 10)
                                    StubSymbol()
                                }
                                LazyVStack {
                                    ForEach(playerDataController.sortedModels()) { playerModel in
                                        //let playerItem = playerModel.item
                                        MainListContentRow(model: playerModel, gradColors: gradientColors)
                                            .onAppear {
                                                ContentView.hasInitialized = true
                                                //dataSource.setCriteria(new: self.criteria)
                                                if (!playerModel.cachedTransactions) {
                                                    playerDataController.loadMoreContentIfNeeded(model: playerModel)
                                                }
                                            }
                                            .padding(.all, 30)
                                    }
                                    
                                    
                                    if playerDataController.isLoading {
                                        ProgressView()
                                            .progressViewStyle(DarkBlueShadowProgressViewStyle())
                                            .scaleEffect(1.5, anchor: .center)
                                    }
                                    
                                }
                            }
                        }
                    }
                    //                        .onAppear(perform: {
                    //                        if (!Universals.firstLoad) {
                    //                            print("Exclusions: \(criteria.excludedSeries)")
                    //                            dataSource.refilterItems(with: Universals.criteria)
                    //                        } else {
                    //                            Universals.firstLoad = false
                    //                        }
                    //
                    //                    })
                )
                .navigationTitle("Best Flips")
                .task(priority: .high) {
                    if (!ContentView.hasInitialized) { //only run this task when the view has not been initialized
                        await playerDataController.cacheSequentialPage()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        refreshButton
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Tap a card name for more info")
                            .italic()
                            .font(.system(size: 11))
                            .lineLimit(1)
                            .frame(width: 260)
                        
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        HStack {
                            settingsButton
                            appearanceButton
                                .padding(.trailing, -10)
                        }
                    }
                }
        }
        //.environmentObject(criteria)
    }
    
    private var refreshButton: some View {
        Button {
            playerDataController.reset()
            playerDataController.loadMoreContentIfNeeded(model: REFRESH_MODEL, refresh: true)
        } label: {
            Label("Refresh", systemImage: "arrow.triangle.2.circlepath.circle")
                .scaleEffect(1.5)
                .foregroundColor(.black)
        }
    }
    
    private var settingsButton: some View {
        NavigationLink(destination: CriteriaController(gradientColors: $gradientColors, dataController: playerDataController)) {
            Image(systemName: "gearshape")
                .foregroundColor(.black)
                .scaleEffect(1.5)
        }
    }
    
    private var appearanceButton: some View {
        NavigationLink(destination: AppearanceController(gradientColors: $gradientColors)) {
            Image(systemName: "paintbrush")
                .foregroundColor(.black)
                .scaleEffect(1.5)
        }
    }
}

struct StubSymbol: View {
    var body: some View {
        Image("stubs")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 20, height: 20, alignment: .center)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .background(.gray)
            .previewInterfaceOrientation(.portrait)
    }
}
