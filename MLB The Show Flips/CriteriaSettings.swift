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




struct CriteriaSettings: View {
    
    
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
            Criteria.maxSize = self.maxSize
        }
    }
    
    @State var excludedSeries:[String] = [] {
        didSet  {
            Criteria.excludedSeries = self.excludedSeries
        }
    }
    
    var lastPage = 100
    
    private let maxPageSpan = 20
    
    
    var body: some View {
        NavigationView {
            LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.vertical)
                .overlay(
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack  (spacing: 0){
                    Text("Min Profit: ")
                    TextField("Min profit", value: $minProfit, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .frame(width: 90, height: 20, alignment: .leading)
                    }.padding(.horizontal, 15)
                    Stepper("Starting marketplace page: \(startPage)", onIncrement: {
                        startPage = min(lastPage, endPage-1,startPage+1)
                    }, onDecrement: {
                        startPage = max(1, startPage-1, endPage-maxPageSpan)
                    })
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                    //Spacer()
                    
                    Stepper("Ending marketplace page: \(endPage)", onIncrement: {
                        endPage = min(lastPage, startPage+maxPageSpan, endPage+1)
                    }, onDecrement: {
                        endPage = max(startPage+1, endPage-1)
                    }).padding(.horizontal, 15)
                        .padding(.vertical, 15)
                    VStack (alignment: .center, spacing: 0){
                        Spacer()
                        Text("Max listings shown: \(maxSize)")
                        HStack {
                            Button(action: {
                                maxSize = max(maxSize-1, 1)
                            }, label: {
                                Image(systemName: "minus")
                            }).foregroundColor(.black)
                                .disabled(maxSize <= 1)
                            
                            Slider(value: $maxSize.double, in: 1...30, step: 1)
                                .accentColor(Colors.darkTeal)
                            
                            Button(action: {
                                maxSize = min(maxSize+1, 30)
                            }, label: {
                                Image(systemName: "plus")
                            }).foregroundColor(.black)
                                .disabled(maxSize >= 30)
                        }.foregroundColor(.black)
                            .padding()
                    }
                    }
            }
            )
        }
    }
}

struct CriteriaSettings_Previews: PreviewProvider {
    static var previews: some View {
        CriteriaSettings()
    }
}
