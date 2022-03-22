//
//  ContentView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder
//

import SwiftUI

/**
 A standard `ProgressView` with a dark blue shadow
 */
struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}

//let playerDataController = PlayerDataController()
let REFRESH_MODEL:PlayerDataModel = PlayerDataModel(name: "", uuid: "REFRESH", bestBuy: 0, bestSell: 0, ovr: 0, year: 0, shortPos: "", team: "", series: "", imgURL: URL(string:"https://apple.com")!, fromPage: 0)

/**
 A view which represents a player entry, including its image
 */
struct MainListContentRow: View {
    
    @StateObject var playerModel: PlayerDataModel //this object drives the state of the view, we "own" it
    
    @Binding var gradColors: [Color]
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    var body: some View {
        let calc = Calculator()
        VStack {
            playerModel.image
                .onAppear(perform: {
                    if (playerModel.image == Image(systemName: "photo")) { //if it appears with a defaulted image, go spin a thread to load the correct one
                        Task.init {
                            await playerModel.getImageForModel()
                        }
                    }
                })
            let text = calc.playerFlipDescription(playerModel).title
            HStack (spacing: 0) {
                NavigationLink("\(text)", destination: CardDetailView(playerModel: playerModel, gradientColors: self.$gradColors))
                    .simultaneousGesture(TapGesture().onEnded({
                        Task.init {
                            async let marketData =  playerModel.getMarketDataForModel()
                            if (!playerModel.hasCachedTransactions) {
                                await playerModel.cacheMarketData(marketData)
                            }
                        }
                    }))
                    .foregroundColor(.black)
                    .font(.system(size: 22))
                StubSymbol()
            }
            .transition(.slide.animation(.easeInOut))
            
            Text(calc.playerFlipDescription(playerModel).desc)
                .foregroundColor(Colors.darkGray)
                .font(.system(size: 16))
        }
        .transition(.opacity.combined(with: .scale.animation(.easeInOut(duration: 0.3))))
    }
}


@MainActor //runs all work here on the main thread (DispatchQueue.main)
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
        
        self._playerDataController = StateObject.init(wrappedValue: PlayerDataController())
    }
    
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    
    @State var gradientColors = Colors.backgroundGradientColors
    
    
    @StateObject var playerDataController: PlayerDataController //initialization replaced
    @StateObject var rosterUpdateController: RosterUpdateViewModel = RosterUpdateViewModel()
    
    var loadedPage: Int = Criteria.startPage
    
    var body: some View {
        NavigationView {
            LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay(
                    VStack {
                        HStack(spacing: 3) {
                            Text("Budget Per Card: \(Criteria.shared.budget)")
                                .padding(.vertical, 10)
                                .font(.system(size: 30, design: .rounded))
                            StubSymbol()
                        }
                        if playerDataController.isLoading {
                            VStack {
                                Text("Loading...")
                                    .font(.system(size: 26, weight: .regular, design: .rounded))
                                ProgressView()
                                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
                                    .scaleEffect(1.5, anchor: .center)
                            }
                        }
                        ScrollView{
                            
                            LazyVStack {
                                ForEach(playerDataController.sortedModels()) { playerModel in
                                    //let playerItem = playerModel.item
                                    MainListContentRow(playerModel: playerModel, gradColors: $gradientColors)
                                        .onAppear {
                                            ContentView.hasInitialized = true
                                            //dataSource.setCriteria(new: self.criteria)
                                            if (!playerModel.hasCachedTransactions) {
                                                playerDataController.loadMoreContentIfNeeded(model: playerModel)
                                            }
                                        }
                                        .padding(.all, 30)
                                }
                                
                                

                                
                            }
                        }
                    }
                )
                .navigationTitle("Best Flips")
                .task(priority: .high) {
                    if (!ContentView.hasInitialized) { //only run this task when the view has not been initialized
                        await playerDataController.cacheSequentialPage()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack {
                            rosterUpdateButton
                            refreshButton
                        }
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
    }
    
    public var refreshButton: some View {
        Button {
            playerDataController.reset()
            playerDataController.loadMoreContentIfNeeded(model: REFRESH_MODEL, refresh: true)
        } label: {
            Label("Refresh", systemImage: "arrow.triangle.2.circlepath.circle")
                .scaleEffect(1.5)
                .foregroundColor(.black)
        }
    }
    
    public var rosterUpdateButton: some View {
        NavigationLink(destination: RosterUpdateHistoryView(gradColors: gradientColors, rosterUpdateController: rosterUpdateController)) {
            
            Image(systemName: "person.fill.checkmark")
                .foregroundColor(.black)
                .scaleEffect(1.5)
        }
        .simultaneousGesture(TapGesture().onEnded {
            Task {
                await rosterUpdateController.fetchUpdateHistory()
            }
        })
        
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
