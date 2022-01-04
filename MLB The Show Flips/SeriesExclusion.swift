//
//  SeriesExclusion.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI

struct SeriesExclusion: View {
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"]
    @State private var selection = Set<String>()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var backBtn : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack (spacing: 3){
            Image(systemName: "chevron.backward")
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                Text("Back").bold()
            }
        }
    }
    
    var body: some View {
            //NavigationView {
        LinearGradient(gradient: Gradient(colors: Colors.backgroundGradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
        VStack{
                List(cardSeries, id: \.self, selection: $selection) { series in
                    Text(series)
                }
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
            .background(.red)
        )
        }
}



struct SeriesExclusion_Previews: PreviewProvider {
    static var previews: some View {
        SeriesExclusion()
    }
}
