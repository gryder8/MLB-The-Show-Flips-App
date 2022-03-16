//
//  RosterUpdateHistory.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import SwiftUI

struct RosterUpdateHistoryView: View {
    
    @ObservedObject var rosterUpdateController: RosterUpdateController
    @Binding var gradColors: [Color]
    
    @State var searchText: String = ""
    
    var searchResults:[RosterUpdateEntry] {
        if (searchText.isEmpty) {
            return rosterUpdateController.updateHistory.roster_updates
        } else {
            return rosterUpdateController.updateHistory.roster_updates.filter { update in update.name.contains(searchText) }
        }
    }
    
    init(gradColors: [Color], rosterUpdateController ruc: RosterUpdateController) {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .clear
        
        _gradColors = Binding.constant(gradColors)
        _rosterUpdateController = ObservedObject.init(initialValue: ruc)
    }
    
    
    var body: some View {
        //let listEntries = rosterUpdateController.updateHistory.roster_updates

        LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay (
                VStack {
                    List(searchResults) { entry in
                        NavigationLink("\(entry.name)", destination: RosterUpdateView(rosterUpdateController: self.rosterUpdateController))
                            .listRowBackground(Color.green)
                            .foregroundColor(.black)
//                            .simultaneousGesture(TapGesture().onEnded {
//                                Task.init {
//                                    await rosterUpdateController.fetchUpdateForID(entry.id)
//                                }
//                            })
                    }
                    .listStyle(.automatic)
                    .searchable(text: $searchText, prompt: "Search Updates")
                }
            )
    }
}

struct RosterUpdateHistoryView_Previews: PreviewProvider {
    static var testColors: [Color] = [.blue, .red]
    static var ruController = RosterUpdateController()
    static var previews: some View {
        RosterUpdateHistoryView(gradColors: testColors, rosterUpdateController: ruController)
    }
}
