//
//  CriteriaSettings.swift
//  AsyncAwaitPattern
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI

struct CriteriaSettings: View {
    @State var minProfit = 5000
    @State var budget = 45000
    @State var startPage = 1
    @State var endPage = 1
    @State var maxSize = 20
    @State var excludedSeries:[String] = []
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    TextField("Min profit", value: $minProfit, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    TextField("Budget", value: $budget, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    TextField("Min profit", value: $minProfit, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
            }
        }
    }
}

struct CriteriaSettings_Previews: PreviewProvider {
    static var previews: some View {
        CriteriaSettings()
    }
}
