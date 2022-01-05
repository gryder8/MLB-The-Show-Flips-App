//
//  CriteriaSettings.swift
//  AsyncAwaitPattern
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI

extension Int {
    var double: Double {
        get { Double(self) }
        set { self = Int(newValue) }
    }
}




struct CriteriaController: View {
    
    
    init() {} //empty
    
    @State var minProfit = 5000 {
        didSet  {
            Criteria.minProfit = self.minProfit
        }
    }
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
    
    
    var body: some View {
        //NavigationView {
        LinearGradient(gradient: Gradient(colors: Colors.backgroundGradientColors), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                GeometryReader { geometry in
                    let leftEdge = geometry.safeAreaInsets.leading + 50
                    VStack(alignment: .leading) {
                        HStack  (spacing: 0){
                            Text("Min Profit: ")
                            TextField("Min profit", value: $minProfit, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .frame(width: 90, height: 20, alignment: .leading)
                        }.padding(.horizontal, leftEdge)
                        Stepper("Starting marketplace page: \(startPage)", onIncrement: {
                            startPage = min(lastPage, endPage-1,startPage+1)
                        }, onDecrement: {
                            startPage = max(1, startPage-1, endPage-maxPageSpan)
                        })
                            .padding(.horizontal, leftEdge)
                            .padding(.vertical, 15)
                            .hidden()
                        
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
                        .navigationBarTitle(Text("Settings"), displayMode: .inline)
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
                .cornerRadius(20)
                
            
        }
    }
}

struct CriteriaController_Previews: PreviewProvider {
    static var previews: some View {
        CriteriaController()
    }
}
