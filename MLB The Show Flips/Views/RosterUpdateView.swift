//
//  RosterUpdateView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import SwiftUI

struct RosterUpdateView: View {
    
    @ObservedObject var rosterUpdateController: RosterUpdateController
    
    
    var body: some View {
        let items = Array(rosterUpdateController.updates.values)
        if (rosterUpdateController.isFetching) {
            ProgressView()
        } else {
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(items) { item in //id is a UUID()
                        RosterUpdateItemView(rosterUpdate: item)
                    }
                }
            }
            //This is causing it to pop back
            .task {
                await rosterUpdateController.fetchUpdateForID(21) //if I go this route, I need to pass an ID into the struct
            }
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
            Text("\(playerChange.name)")
            ScrollView(.horizontal, showsIndicators: true) {
                HStack (alignment: .center, spacing: 20) {
                    Spacer()
                    ForEach(playerChange.changes) { attribChange in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(attribChange.attributeUIColor)
                                .frame(width: 90, height: 90, alignment: .center)
                            VStack {
                                Text("\(attribChange.name)")
                                    .padding(.top, 5)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 70, height: 45, alignment: .center)
                                        .foregroundColor(.gray)
                                        .offset(x: 0, y: 5)
                                    Text("\(attribChange.current_value)")
                                }
                                
                            }
                        }
                        .padding()
                        
                    }
                    Spacer()
                }
            }
            
        }
    }
}

struct RosterUpdateView_Previews: PreviewProvider {
    static var ruController = RosterUpdateController()
    static var previews: some View {
        RosterUpdateView(rosterUpdateController: ruController)
    }
}
