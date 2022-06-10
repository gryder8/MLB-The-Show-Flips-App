//
//  RosterUpdateHistory.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 3/15/22.
//

import SwiftUI

struct RosterUpdateHistoryView: View {
    
    @ObservedObject var rosterUpdateController: RosterUpdateViewModel
    @Binding var gradColors: [Color]
    
    @State var searchText: String = ""
    
    var searchResults:[RosterUpdateEntry] {
        if (searchText.isEmpty) {
            //print("***Updates: \(rosterUpdateController.updateHistory.roster_updates)")
            return rosterUpdateController.updateHistory.roster_updates
        } else {
            return rosterUpdateController.updateHistory.roster_updates.filter { update in update.name.contains(searchText) }
        }
        
    }
    
    init(gradColors: [Color], rosterUpdateController ruc: RosterUpdateViewModel) {
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().titleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar.appearance().barTintColor = .black
        UITableView.appearance().backgroundColor = .clear
        
        _gradColors = Binding.constant(gradColors)
        _rosterUpdateController = ObservedObject.init(initialValue: ruc)
    }
    
    //TODO: NavigationStack and $path time; refer to naviagation cookbook WWDC 22 talk
    
    //@State private var presentedEntries = NavigationPath()
    
    var body: some View {
        //let listEntries = rosterUpdateController.updateHistory.roster_updates
        
        
            
            LinearGradient(colors: gradColors, startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .overlay (
                    
                    //VStack{
                    //ScrollView {
                    NavigationStack {
                        VStack {
                            List(searchResults) { entry in
                                NavigationLink("\(entry.name)") {
                                    RosterUpdateView(updateID: entry.id, gradColors: self.gradColors, rosterUpdateVM: self.rosterUpdateController)
                                }
                                .listRowBackground(Color.clear)
                                .foregroundColor(.black)
                                //                                .simultaneousGesture(TapGesture().onEnded { value in
                                //                                    print("fetching update with id: \(entry.id)")
                                //                                    Task(priority: .high) {
                                //                                        await self.rosterUpdateController.fetchUpdateForID(entry.id)
                                //                                    }
                                //                                })
                                //                                .listRowBackground(Color.clear)
                                //                                .foregroundColor(.black)
                            }
                            .listStyle(.inset)
                            .padding(.top, 10)
                            .searchable(text: $searchText, prompt: "Search Updates")
                        }
                        .navigationTitle("Roster Updates")
                        .navigationBarTitleDisplayMode(.automatic)
                        Spacer()
                    }
                        .background(.red)
                        //.padding(.top, -150)
                )
    }
}

struct UpdateEntryView: View {
    var gradColors: [Color]
    var name: String
    var id: Int
    var controller: RosterUpdateViewModel
    init(rosterUpdateEntry: RosterUpdateEntry, controller: RosterUpdateViewModel, gradColors: [Color]) {
        self.name = rosterUpdateEntry.name
        self.id = rosterUpdateEntry.id
        self.controller = controller
        self.gradColors = gradColors
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 300, height: 50, alignment: .center)
                .foregroundColor(.green)
            NavigationLink("\(name)", destination: RosterUpdateView(updateID: self.id, gradColors: gradColors, rosterUpdateVM: self.controller))
                .listRowBackground(Color.green)
                .foregroundColor(.black)
//                .simultaneousGesture(TapGesture().onEnded {
//                    print("fetching update with id: \(self.id)")
//                    Task(priority: .high) {
//                        await controller.fetchUpdateForID(self.id)
//                    }
//                })
            
        }
        .padding()
    }
}

struct RosterUpdateHistoryView_Previews: PreviewProvider {
    static var testColors: [Color] = [.blue, .red]
    static var ruController = RosterUpdateViewModel()
    static var previews: some View {
        RosterUpdateHistoryView(gradColors: testColors, rosterUpdateController: ruController)
    }
}
