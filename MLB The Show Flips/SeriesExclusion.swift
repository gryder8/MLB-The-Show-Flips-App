//
//  SeriesExclusion.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI

struct ListRow: View {
    
    var text = ""
    var selected = false
    let enabledGradientColors:[Color] = [.green, Colors.whiteSmoke]
    let disabledGradientColors:[Color] = [Colors.darkRed, Colors.whiteSmoke]
    
    init(_ text: String, disabled: Bool) {
        self.text = text
        self.selected = disabled
    }
    
    var body: some View {
        Text(self.text)
            .listRowBackground(selected ?
                               LinearGradient(colors: disabledGradientColors, startPoint: .leading, endPoint: .trailing)
                               : LinearGradient(colors: enabledGradientColors, startPoint: .leading, endPoint: .trailing)
            )
    }
}


struct SeriesExclusion: View {
    
    init() {
        UINavigationBar.appearance().backgroundColor = Colors.UIteal
        //UINavigationBar.appearance().standardAppearance
    }
    
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"]
    @State private var selection: Set<String> = Set(Criteria.excludedSeries.map{$0})
//    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    //    var backBtn : some View { Button(action: {
    //        self.presentationMode.wrappedValue.dismiss()
    //        }) {
    //            HStack (spacing: 3){
    //            Image(systemName: "chevron.backward")
    //                .aspectRatio(contentMode: .fit)
    //                .foregroundColor(.blue)
    //                Text("Back").bold()
    //            }
    //        }
    //    }
    
    
    
    var body: some View {
        //NavigationView {
        LinearGradient(gradient: Gradient(colors: Colors.backgroundGradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                VStack{
                    List(cardSeries, id: \.self, selection: $selection) { series in
                        ListRow(series, disabled: selection.contains(series))
                        
                    }
                    .listStyle(.insetGrouped)
                    .onDisappear(perform: {
                        Criteria.excludedSeries = Array(selection)
                    })
                    .navigationTitle("Excluded Series")
                    .navigationBarTitleDisplayMode(.large)
                    //.navigationBarBackButtonHidden(false)
                    .toolbar{
                        //                    ToolbarItem(placement: .navigationBarLeading) {
                        //                        backBtn.scaleEffect(1.1)
                        //                    }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                                .scaleEffect(1.1)
                        }
                    }
                    
                    //}
                }
                    .navigationBarTitle(Text("Exclude Card Series"), displayMode: .inline)
                    .foregroundColor(.black)
            )
    }
}



struct SeriesExclusion_Previews: PreviewProvider {
    static var previews: some View {
        SeriesExclusion()
    }
}
