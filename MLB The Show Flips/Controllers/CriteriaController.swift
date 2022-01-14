//
//  CriteriaSettings.swift
//  AsyncAwaitPattern
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI
import Combine

struct CriteriaController: View {
    
    //@ObservedObject var dataSource: ContentDataSource
    
    
    @Binding var gradientColors: [Color]
    
    //@EnvironmentObject var criteria:Criteria
    
    @State var minProfit = String(Criteria.initProfit)
    
    
    @FocusState private var minProfitFocused: Bool
    @FocusState private var budgetFocused: Bool
    
    @State var budget = String(Criteria.initBudget)
    
    @ObservedObject var dataController: PlayerDataController
    
    let startPage = Criteria.startPage
    
    @State var endPage = 3 {
        didSet  {
            Criteria.shared.endPage = self.endPage
        }
    }
    
    
    @State var excludedSeries:[String] = [] {
        didSet  {
            Criteria.shared.excludedSeries = self.excludedSeries
        }
    }
    
    var lastPage = 100
    
    private let maxPageSpan = 20
    
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"] //alphabetized as is
    @State private var selection = Set<String>()
    @State private var showMinProfitAlert = false
    @State private var showBudgetAlert = false
    @State private var showErrorAlert = false
    
    
    var body: some View {
        
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                GeometryReader { geometry in
                    let leftEdge = geometry.safeAreaInsets.leading + 50
                    let mid = (geometry.safeAreaInsets.trailing - geometry.safeAreaInsets.leading) / 2
                    VStack (alignment: .leading) {
                        VStack {
                            HStack  (spacing: 0){
                                Text("Min Profit: ").bold()
                                TextField("Min Profit", text: $minProfit)
                                    .onReceive(Just(minProfit)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.minProfit = filtered
                                        }
                                    }
                                    .focused($minProfitFocused)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .background(.white)
                                    .cornerRadius(8)
                                
                                Button("Enter") {
                                    minProfitFocused = false
                                    
                                    
                                    if let profitValueAsInt:Int = Int(self.minProfit) {
                                        Criteria.shared.minProfit = profitValueAsInt
                                        dataController.refilterDataForNewCriteria()
                                        showMinProfitAlert.toggle()
                                    } else {
                                        showErrorAlert.toggle()
                                    }
                                    
                                }
                                .alert("Min Profit set to \(Criteria.shared.minProfit) stubs", isPresented: $showMinProfitAlert) {
                                    Button("Dismiss"){}
                                }
                                .alert("Enter a valid number!", isPresented: $showErrorAlert) {
                                    Button("OK"){}
                                }
                                .buttonStyle(.bordered)
                                .padding(.horizontal, mid)
                                .foregroundColor(.white)  .background(Colors.midGray)
                                .cornerRadius(8)
                                .padding(.leading, 10)
                                .padding(.trailing, 30)
                                
                                
                                Spacer()
                            }
                            
                            HStack  (spacing: 0){
                                Text("Budget Per Card:").bold()
                                    .padding(.trailing, 10.0)
                                    .lineLimit(1)
                                    .frame(width: 146)
                                //.padding(.trailing, 5)
                                
                                TextField("Budget", text: $budget)
                                    .onReceive(Just(budget)) { newValue in
                                        let filtered = newValue.filter { "0123456789".contains($0) }
                                        if filtered != newValue {
                                            self.budget = filtered
                                        }
                                    }
                                    .focused($budgetFocused)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.numberPad)
                                    .background(.white)
                                    .cornerRadius(8)
                                    .padding(.trailing, 10)
                                
                                Button("Enter") {
                                    budgetFocused = false
                                    
                                    
                                    if let budgetValueAsInt:Int = Int(self.budget) {
                                        Criteria.shared.budget = budgetValueAsInt
                                        dataController.refilterDataForNewCriteria()
                                        showBudgetAlert.toggle()
                                    } else {
                                        showErrorAlert.toggle()
                                    }
                                    
                                }
                                .alert("Budget set to \(Criteria.shared.budget) stubs", isPresented: $showBudgetAlert) {
                                    Button("Dismiss"){}
                                }
                                .alert("Enter a valid number!", isPresented: $showErrorAlert) {
                                    Button("OK"){}
                                }
                                .buttonStyle(.bordered)
                                .padding(.horizontal, mid)
                                .foregroundColor(.white)            .background(Colors.midGray)
                                .cornerRadius(8)
                                //.padding(.leading, 10)
                                .padding(.trailing, -25)
                                
                                Spacer()
                            }
                            
                        }.padding(.horizontal, leftEdge)
                        
//                        Stepper("Ending marketplace page: \(endPage)", onIncrement: {
//                            endPage = min(Criteria.shared.endPage, endPage+1)
//                        }, onDecrement: {
//                            endPage = max(Criteria.startPage, endPage-1)
//                        }).padding(.horizontal, leftEdge)
                        
                        excludeSeriesButton
                            .padding(.leading, leftEdge-5)
                            .padding(.top, 8)
                        
                        Spacer()
                    }.padding(.top, 30)
                        .navigationBarTitle(Text("Settings"), displayMode: .large)
                }
            )
    }
    
    private var excludeSeriesButton: some View {
        NavigationLink(destination: SeriesExclusion(gradColors: gradientColors, dataController: self.dataController)) {
            HStack {
                Text("Exclude Card Series")
                Image(systemName: "arrow.right")
            }.foregroundColor(.white)
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .frame(width: 200, height: 40)
                .background(Colors.midGray)
                .cornerRadius(8)
            
            
        }
    }
    
}

struct CriteriaController_Previews: PreviewProvider {
    static var ds = PlayerDataController()
    static var testIMGURL: URL = URL(string: "https://mlb21.theshow.com/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBczVzIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a63051376496444a959d408eeb385c660d229548/e53423a698b7afe59590c90a70cd448d.jpg")!
    //@ObservedObject static var model = PlayerDataModel(name: "Test", uuid: "224466", bestBuy: 93673, bestSell: 125678, ovr: 99, year: 2021, shortPos: "TP", team: "Test", series: "Test", imgURL: testIMGURL, fromPage: 1)
    @State static var testColors: [Color] = [.orange, .black]
    
    static var previews: some View {
        CriteriaController(gradientColors: $testColors, dataController: ds)
    }
}
