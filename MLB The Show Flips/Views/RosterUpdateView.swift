//
//  RosterUpdateView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import SwiftUI

struct RosterUpdateView: View { //top-most view!
    
    @ObservedObject var rosterUpdateViewModel: RosterUpdateViewModel
    var gradColors: [Color]
    var updateId: Int
    
    @State var loadingUpdate = true
    
    init(updateID: Int, gradColors: [Color], rosterUpdateVM ruVM: RosterUpdateViewModel) {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .clear
        
        self.updateId = updateID
        self.gradColors = gradColors
        _rosterUpdateViewModel = ObservedObject.init(initialValue: ruVM)
    }
    
    var body: some View {
        let item = rosterUpdateViewModel.updates[updateId] ?? RosterUpdate(attribute_changes: [])
        
        if (loadingUpdate) {
            LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay (
                    VStack {
                        Text("Loading...")
                            .font(.system(size: 26, weight: .regular, design: .rounded))
                        ProgressView()
                            .progressViewStyle(DarkBlueShadowProgressViewStyle())
                            .scaleEffect(1.5, anchor: .center)
                        Spacer()
                    }
                        .task {
                            print("Fetching update...")
                            DispatchQueue.main.async {
                                loadingUpdate = true
                            }
                            await self.rosterUpdateViewModel.fetchUpdateForID(updateId)
                            
                            DispatchQueue.main.async {
                                loadingUpdate = false
                                print("Fetched update!")
                            }
                        }
                )
        } else {
            LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay (
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            //ForEach(items) { item in //id is a UUID()
                            RosterUpdateItemView(rosterUpdate: item)
                        }
                    }
                    
                )
        }
    }
}

struct RosterUpdateItemView: View {
    var entry: RosterUpdate
    
    init(rosterUpdate: RosterUpdate) {
        self.entry = rosterUpdate
    }
    
    var body: some View {
        
        ForEach(entry.attribute_changes) { playerChange in
            OverallChangeView(ratingChange: playerChange)
            if (playerChange.changes.isEmpty) {
                HStack {
                    Spacer()
                    Text("No Attribute Changes!")
                        .font(.headline)
                        .italic()
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack (alignment: .center, spacing: 20) {
                        Spacer()
                        ForEach(playerChange.changes) { attribChange in
                            AttributeView(attribChange: attribChange)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct OverallChangeView: View {
    
    var name: String
    var oldRating: Int
    var newRating: Int
    var trendSymbol: String
    var trendAmt: Int
    
    init (ratingChange: RosterUpdateRatingChange) {
        self.name = ratingChange.name
        self.oldRating = ratingChange.old_rank
        self.newRating = ratingChange.current_rank
        self.trendSymbol = ratingChange.trend_symbol
        self.trendAmt = ratingChange.trend_display
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 50, alignment: .center)
                .foregroundColor(.clear)
            HStack {
                Text("\(name): \(oldRating)")
                Image(systemName: "arrow.right")
                Text("\(newRating)")
            }
            .font(.system(size: 24, weight: .medium, design: .rounded))
            .foregroundColor(.black)
        }
    }
}

struct AttributeView: View {
    
    var color: Color
    var attribValue: String
    var attribName: String
    var delta: String
    
    init(attribChange: RosterUpdateAttributeChange) {
        self.color = attribChange.attributeUIColor
        self.attribValue = attribChange.current_value
        self.attribName = attribChange.name
        self.delta = attribChange.delta
    }
    
    var body: some View {
        
        let signs = CharacterSet(charactersIn: "+-")
        
        ZStack {
            //GeometryReader { geom in
            
            
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(color)
            //.scaledToFit()
                .frame(width: 100, height: 100, alignment: .center)
            VStack {
                Text("\(attribName)")
                    .padding(.top, 5)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                Text("\(attribValue)")
                    .font(.system(size: 16, weight: .regular , design: .rounded))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 35, alignment: .center)
                        .foregroundColor(delta.contains("+") ? .green : .red)
                    HStack (spacing: 3) {
                        Text("\(delta.trimmingCharacters(in: signs))")
                        Image(systemName: delta.contains("+") ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                }
                .padding(.bottom, 10)
                
            }
        }
        .padding()
    }
}

struct RosterUpdateView_Previews: PreviewProvider {
    static var ruController = RosterUpdateViewModel()
    static let change = RosterUpdateAttributeChange(name: "SPD", current_value: "90", direction: "positive", delta: "-7", color: "blue")
    static let overallChange = RosterUpdateRatingChange(name: "Trevor Bauer", team: "Lodgers", current_rarity: "Diamond", old_rarity: "Diamond", obfuscated_id: "34556464", current_rank: 99, old_rank: 88, changes: [change])
    static let testColors: [Color] = [.blue, .red]
    static var previews: some View {
        Group {
            RosterUpdateView(updateID: 21, gradColors: testColors, rosterUpdateVM: ruController)
            AttributeView(attribChange: change)
            OverallChangeView(ratingChange: overallChange)
            RosterUpdateItemView(rosterUpdate: RosterUpdate(attribute_changes: []))
        }
    }
}
