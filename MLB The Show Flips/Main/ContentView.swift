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
}



struct DarkBlueShadowProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .shadow(color: Color(red: 0, green: 0, blue: 0.6),
                    radius: 4.0, x: 1.0, y: 2.0)
    }
}


struct MainListContentRow: View {
    var criteria: Criteria
    var playerListing:PlayerListing
    var playerItem:PlayerItem
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    init (playerListing: PlayerListing, playerItem: PlayerItem, criteriaObj: Criteria) {
        self.playerListing = playerListing
        self.playerItem = playerItem
        self.criteria = criteriaObj
    }
    
    var body: some View {
        let calc = Calculator(criteriaInst: criteria)
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

struct Universals: ViewModifier {
    static var criteria = Criteria()
    static var firstLoad = true
    
    func body(content: Content) -> some View {
        content
            .environmentObject(Self.criteria)
    }
}


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
        dataSource = ContentDataSource(criteriaInst: Universals.criteria)
    }
    
    
    //@ObservedObject var viewModel = ContentViewModel()
    //@GestureState var dragAmount = CGSize.zero
    //@State var hidesNavBar = false
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    
    @StateObject var criteria = Universals.criteria
    
    @ObservedObject var dataSource:ContentDataSource = ContentDataSource(criteriaInst: Criteria()) //initialization replaced
    
    var loadedPage: Int = Criteria.startPage
    
    var body: some View {
        NavigationView {
            LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay(
                    ScrollView {
                        VStack {
                            Text("Budget Per Card: \(criteria.budget)")
                                .padding(.vertical, 10)
                            LazyVStack {
                                ForEach(dataSource.items) { playerListing in
                                    let playerItem = playerListing.item
                                    MainListContentRow(playerListing: playerListing, playerItem: playerItem, criteriaObj: criteria)
                                        .onAppear {
                                            dataSource.setCriteria(new: self.criteria)
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
                    }.onAppear(perform: {
                        if (!Universals.firstLoad) {
                            dataSource.refilterItems(with: Universals.criteria)
                        } else {
                            Universals.firstLoad = false
                        }
                        
                    })
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
        .environmentObject(criteria)
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
        NavigationLink(destination: CriteriaController(contentDataSource: dataSource).modifier(Universals())) {
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
