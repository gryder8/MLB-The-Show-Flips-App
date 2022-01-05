//
//  CriteriaSettings.swift
//  AsyncAwaitPattern
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI
import Combine

extension Int {
    var double: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}




struct CriteriaController: View {
    
    
    init() {} //empty
    
    @State var minProfit = String(Criteria.minProfit)
    
    
    @FocusState private var minProfitFocused: Bool
    
    @State var budget = 45000 {
        didSet  {
            Criteria.budget = self.budget
        }
    }
    @State var startPage = 1 {
        didSet  {
            Criteria.startPage = self.startPage
        }
    }
    @State var endPage = 3 {
        didSet  {
            Criteria.endPage = self.endPage
        }
    }
    @State var maxSize:Int = 20 {
        didSet  {
            Criteria.maxCardsAtOnce = self.maxSize
        }
    }
    
    @State var excludedSeries:[String] = [] {
        didSet  {
            Criteria.excludedSeries = self.excludedSeries
        }
    }
    
    var lastPage = 100
    
    private let maxPageSpan = 20
    
    private let cardSeries:[String] = ["2021 All Star", "2021 Postseason", "2nd Half", "All-Star", "Awards", "Finest", "Future Stars", "Home Run Derby", "Live", "Milestone", "Monthly Awards", "Postseason", "Prime", "Prospect", "Rookie", "Signature", "The 42", "Topps Now", "Veteran"]
    @State private var selection = Set<String>()
    @State private var showAlert = false
    
    var body: some View {
        //NavigationView {
        
        
        
        LinearGradient(gradient: Gradient(colors: Colors.backgroundGradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                GeometryReader { geometry in
                    let leftEdge = geometry.safeAreaInsets.leading + 50
                    let mid = (geometry.safeAreaInsets.trailing - geometry.safeAreaInsets.leading) / 2
                    VStack (alignment: .leading) {
                        VStack {
                            HStack  (spacing: 0){
                                Text("Min Profit: ")
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
                                    Criteria.minProfit = Int(self.minProfit) ?? 5000
                                    showAlert.toggle()
                                }
                                .alert("Min Profit Set to \(Criteria.minProfit) stubs", isPresented: $showAlert) {
                                    Button("Dismiss"){}
                                }
                                .buttonStyle(.bordered)
                                .padding(.horizontal, mid)
                                .foregroundColor(.white)                     .background(Colors.midGray)
                                .cornerRadius(8)
                                .padding(.leading, 10)
                                .padding(.trailing, 30)
                                
                                Spacer()
                            }
                            
                        }.padding(.horizontal, leftEdge)
                        
                        Stepper("Ending marketplace page: \(endPage)", onIncrement: {
                            endPage = min(lastPage, startPage+maxPageSpan, endPage+1)
                        }, onDecrement: {
                            endPage = max(startPage+1, endPage-1)
                        }).padding(.horizontal, leftEdge)
                        
                        excludeSeriesButton
                            .padding(.leading, leftEdge-5)
                            .padding(.top, 8)
                        
                        Spacer()
                    }.padding(.top, 30)
                        .navigationBarTitle(Text("Settings"), displayMode: .large)
                }
            )
        //}
    }
    
    private var excludeSeriesButton: some View {
        NavigationLink(destination: SeriesExclusion()) {
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
    static var previews: some View {
        CriteriaController()
    }
}
