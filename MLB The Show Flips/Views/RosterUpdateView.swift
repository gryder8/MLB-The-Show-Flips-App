//
//  RosterUpdateView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import SwiftUI

struct RosterUpdateView: View {
    
    @ObservedObject var rosterUpdateController: RosterUpdateController
    var gradColors: [Color]
    
    init(gradColors: [Color], rosterUpdateController ruc: RosterUpdateController) {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .clear
        
        self.gradColors = gradColors
        _rosterUpdateController = ObservedObject.init(initialValue: ruc)
    }
    
    var body: some View {
        let items = Array(rosterUpdateController.updates.values)
        
        if (rosterUpdateController.isFetching) {
            LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay (
                    ProgressView()
                )
        } else {
            LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay (
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(items) { item in //id is a UUID()
                                RosterUpdateItemView(rosterUpdate: item)
                            }
                        }
                    }
                )
            //This is causing it to pop back
            //            .task {
            //                await rosterUpdateController.fetchUpdateForID(21) //if I go this route, I need to pass an ID into the struct
            //            }
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
            ScrollView(.horizontal, showsIndicators: true) {
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
                .foregroundColor(.teal)
            HStack {
                Text("\(name): \(oldRating)")
                Image(systemName: "arrow.right")
                Text("\(newRating)")
            }
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
                Text("\(delta)")
                    .font(.system(size: 16, weight: .regular , design: .rounded))
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 50, height: 35, alignment: .center)
                        .foregroundColor(delta.contains("+") ? .green : .red)
                    HStack (spacing: 3) {
                        Text("\(attribValue)")
                        Image(systemName: delta.contains("+") ? "arrow.up" : "arrow.down")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                }
                .padding(.bottom, 10)
                
            }
        }
        .padding()
        // }
    }
}

struct RosterUpdateView_Previews: PreviewProvider {
    static var ruController = RosterUpdateController()
    static let change = RosterUpdateAttributeChange(name: "SPD", current_value: "90", direction: "positive", delta: "-7", color: "blue")
    static let overallChange = RosterUpdateRatingChange(name: "Trevor Bauer", team: "Lodgers", current_rarity: "Diamond", old_rarity: "Diamond", obfuscated_id: "34556464", current_rank: 99, old_rank: 88, changes: [change])
    static let testColors: [Color] = [.blue, .red]
    static var previews: some View {
        Group {
            RosterUpdateView(gradColors: testColors, rosterUpdateController: ruController)
            AttributeView(attribChange: change)
            OverallChangeView(ratingChange: overallChange)
        }
    }
}
