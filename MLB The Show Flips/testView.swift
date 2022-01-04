//
//  testView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/3/22.
//

import SwiftUI


//                    VStack (alignment: .center, spacing: 0){
//                        Spacer()
//                        Text("Max listings shown: \(maxSize)")
//                        HStack {
//                            Button(action: {
//                                maxSize = max(maxSize-1, 1)
//                            }, label: {
//                                Image(systemName: "minus")
//                            }).foregroundColor(.black)
//                                .disabled(maxSize <= 1)
//
//                            Slider(value: $maxSize.double, in: 1...30, step: 1)
//                                .accentColor(Colors.darkTeal)
//
//                            Button(action: {
//                                maxSize = min(maxSize+1, 30)
//                            }, label: {
//                                Image(systemName: "plus")
//                            }).foregroundColor(.black)
//                                .disabled(maxSize >= 30)
//                        }.foregroundColor(.black)
//                            .padding()
//                    }



struct testView: View {
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"]
    @State private var selection = Set<String>()
    var body: some View {
        VStack {
            HStack {
            Text("+6000 ")
                    .font(.system(size: 22, design: .rounded))
                    //.font(.system(size: 30))
            Image("stubs")
                    .resizable()
                    //.scaleEffect(0.08)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20, alignment: .topLeading)
            }.padding(.top, 30.0)
            List(cardSeries, id: \.self, selection: $selection) { series in
                Text(series)
            }
            .padding(.all)
            .navigationTitle("Exclude Card Series:")
            .toolbar {
                EditButton()
            .frame(width: 500, height: 200, alignment: .bottom)
            }
            
            Text("hello world")
                .padding(.top, 15.0)
            Image(systemName: "tray.2")
            Image(systemName: "tray.2")
            Image(systemName: "tray.2")
        }
    }
}

struct testView_Previews: PreviewProvider {
    static var previews: some View {
        testView()
    }
}
