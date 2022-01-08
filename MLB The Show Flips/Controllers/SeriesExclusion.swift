//
//  SeriesExclusion.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI


//let enabledGradientColors:[Color] = [Colors.pastelGreen, Colors.glacier]
let enabledGradient = LinearGradient(colors: [Colors.pastelGreen, Colors.glacier], startPoint: .leading, endPoint: .trailing)
//let disabledGradientColors:[Color] = [Colors.darkRed, Colors.glacier]
let disabledGradient = LinearGradient(colors: [Colors.darkRed, Colors.glacier], startPoint: .leading, endPoint: .trailing)


struct SeriesExclusion: View {
    
    @Binding var gradColors: [Color]
    @State private var selection: Set<String> = Set<String>()
    //@EnvironmentObject var criteria:Criteria
    
    
    init(gradColors: [Color]) {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .clear
        
        _gradColors = Binding.constant(gradColors)
        
        //UINavigationBar.appearance().standardAppearance
        //print(criteria.excludedSeries)
    }
    
    
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"]
    
    
    
    var body: some View {
        LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                VStack{
                    List(cardSeries, id: \.self, selection: $selection) { series in
                        Text(series)
                            .listRowBackground(
                                selection.contains(series) ? disabledGradient :  enabledGradient
                            )
                            .listRowSeparatorTint(.black)
                    }
                    .onAppear(perform: {
                        selection = Set(Criteria.shared.excludedSeries.map{$0})
                    })
                    .listStyle(.insetGrouped)
                    .onDisappear(perform: {
                        Criteria.shared.excludedSeries = Array(selection)
                        print(Criteria.shared.excludedSeries)
                    })
                    .navigationTitle("Manage Series")
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                                .scaleEffect(1.1)
                        }
                    }
                    
                }
                    .navigationBarTitle(Text("Exclude Card Series"), displayMode: .inline)
                    .foregroundColor(.black)
                //.navigationBar
            )
    }
}



struct SeriesExclusion_Previews: PreviewProvider {
    static var testColors: [Color] = [.orange, .black]
    static var previews: some View {
        SeriesExclusion(gradColors: testColors)
    }
}
