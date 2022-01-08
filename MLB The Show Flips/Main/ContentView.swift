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
let NIL_MODEL:PlayerDataModel = PlayerDataModel(name: "", uuid: "NIL", bestBuy: 0, bestSell: 0, ovr: 0, year: 0, shortPos: "", team: "", series: "", imgURL: URL(string:"https://apple.com")!, fromPage: 0)


struct MainListContentRow: View {
    
    var playerModel: PlayerDataModel
//    var playerListing: PlayerListing
//    var playerItem:PlayerItem
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    init (model: PlayerDataModel) {
        self.playerModel = model
    }
    
    var body: some View {
        let calc = Calculator()
        VStack {
//            AsyncImage(url: playerModel.imgURL, transaction: Transaction(animation: .easeInOut)) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .progressViewStyle(DarkBlueShadowProgressViewStyle())
//                        .scaleEffect(1.5, anchor: .center)
//                case .success(let image):
//                    image
//                        .fixedSize(horizontal: true, vertical: true)
//                case .failure:
//                    Image(systemName: "person.crop.circle.badge.exclamationmark")
//                        .scaleEffect(3.5)
//                        .padding(.bottom, 10)
//                        .foregroundColor(.red)
//                @unknown default:
//                    EmptyView()
//                }
//            }
            
            playerModel.image
                .onAppear(perform: {
                    if (playerModel.image == Image(systemName: "photo")) { //if it appears with a defaulted image, go spin a thread to load the correct one
                        Task.init {
                            await playerModel.cacheImage()
                        }
                    }
                })
            
            let text = calc.playerFlipDescription(playerModel).title
            let url: URL = URL(string: "\(urlBaseString + playerModel.uuid)")!
            HStack (spacing: 0){
                Link("\(text)", destination: url)
                    .foregroundColor(.black)
                    .font(.system(size: 22))
                StubSymbol()
            }.transition(.slide.animation(.easeInOut))
            Text(calc.playerFlipDescription(playerModel).desc)
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

//struct Universals: ViewModifier {
//    static var criteria = Criteria()
//    static var firstLoad = true
//
//    func body(content: Content) -> some View {
//        content
//            .environmentObject(Self.criteria)
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
                        VStack {
                            HStack(spacing: 3) {
                                Text("Budget Per Card: \(Criteria.shared.budget)")
                                    .padding(.vertical, 10)
                                StubSymbol()
                            }
                            LazyVStack {
                                ForEach(playerDataController.sortedModels()) { playerModel in
                                    //let playerItem = playerModel.item
                                    MainListContentRow(model: playerModel)
                                        .onAppear {
                                            //dataSource.setCriteria(new: self.criteria)
                                            playerDataController.loadMoreContentIfNeeded(model: playerModel)
                                            
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
                .task {
                    await playerDataController.cacheSequentialPage()
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
            playerDataController.loadMoreContentIfNeeded(model: NIL_MODEL)
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
