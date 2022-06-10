//
//  CardDetailView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/7/22.
//

import SwiftUI
import SwiftUICharts
import Charts

//https://github.com/AppPear/ChartView/
//https://github.com/aunnnn/MovingNumbersView

///DataSeries for SwiftChart
struct DataEntry: Identifiable {
    
    let name: String
    let data: [HistoricalPriceValue]
    
    var id: String { name }
}

/**
 Detail view for each card shown when the name is tapped
 */
struct CardDetailView: View {
    
    func priceHistorySorter(_ h1: HistoricalPriceValue, _ h2: HistoricalPriceValue) -> Bool {
        return h1.dateAsDateObject < h2.dateAsDateObject
    }
    
    private let urlBaseString = "https://mlb22.theshow.com/items/"
    private let calc:Calculator = Calculator()
    @ObservedObject var playerModel: PlayerDataModel //since we want to be able to refresh, we want to observe the changes to this object
    //note that we don't own this object so we use @ObservedObject and not @StateObject
    @Binding var gradientColors: [Color]
    
    
    //    init(playerModel: PlayerDataModel, gradientColors: [Color]) {
    //        _playerModel = ObservedObject.init(initialValue: playerModel)
    //        _gradientColors = Binding.constant(gradientColors)
    //    }
    
    /**
     Link Button
     */
    private var goToWebLink: some View {
        RoundedRectangle(cornerRadius: 8, style: .circular)
            .frame(width: 200, height: 40)
            .foregroundColor(Colors.midGray)
            .overlay(
                Link("View on Web", destination: URL(string: "\(urlBaseString+playerModel.uuid)")!)
                    .scaledToFit()
                    .foregroundColor(.black)
                
            )
    }
    
    @State private var removingOutliersInChart = true
    private var chartData: [DataEntry] {
        if (removingOutliersInChart) {
            return [.init(name: "Profit", data:  playerModel.priceHistoryRemovingOutliers.sorted(by: priceHistorySorter(_:_:)))]
        } else {
            return [.init(name: "Profit", data:  playerModel.price_history.sorted(by: priceHistorySorter(_:_:)))]
        }
    }
    
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                ScrollView {
                    if (playerModel.isFetching) {
                        ProgressView()
                            .progressViewStyle(DarkBlueShadowProgressViewStyle())
                            .scaleEffect(1.5, anchor: .center)
                            .frame(width: 40, height: 40)
                            .padding()
                    } else {
                        VStack { //top level
                            VStack(alignment: .center) { //centering V-Stack for the player img, name and subtitle info
                                
                                playerModel.image
                                
                                Text(playerModel.name)
                                    .foregroundColor(.black)
                                    .font(.system(size: 22))
                                
                                Text(calc.playerFlipDescription(self.playerModel).1)
                                    .foregroundColor(Colors.darkGray)
                                    .font(.system(size: 16))
                            }
                            
                            BuySellProfit(model: playerModel)
                            
                            StubsText(text: "Sales/minute: \(playerModel.transactionsPerMin)", spacing: 5)
                            
                            goToWebLink
                            let histories = calc.getPriceHistoriesForGraph(priceHistory: playerModel.price_history)
                            let rates  = calc.getRates(priceHistory: playerModel.price_history)
                            let chartStyle = ChartStyle(backgroundColor: .clear, accentColor: gradientColors.first!, secondGradientColor: gradientColors.last!, textColor: .black, legendTextColor: .black, dropShadowColor: gradientColors.last!)
                            if #available(iOS 16.0, *) {
                                Text("Daily Profit History")
                                    .font(.system(size: 20, weight: .light, design: .rounded))
                                    .underline()
                                Toggle("Remove Outliers: ", isOn: $removingOutliersInChart)
                                    .padding(.horizontal, 120)
                            } else {
                                Text("Recent Trends")
                                    .font(.system(size: 20, weight: .light, design: .rounded))
                                    .underline()
                            }
                            
                            HStack (spacing: 10){
                                if #available(iOS 16.0, *) {
//                                    chartData = [
//
//                                    ]
                                    Chart(chartData) { dataObj in
                                        ForEach(dataObj.data) { element in
                                            LineMark(
                                                x: .value("Day", element.dateAsDateObject),
                                                y: .value("Profit", element.profit))
                                        }
                                        .symbol(by: .value("Flip Profit", dataObj.name))
                                        .interpolationMethod(.catmullRom)
                                    }
                                    .frame(height: 300)
                                    .padding(.horizontal)
                                } else {
                                    LineChartView(data: histories.bestBuy, title: "Best Buy", style: chartStyle, rateValue: rates.buyRate)
                                    LineChartView(data: histories.bestSell, title: "Best Sell", style: chartStyle, rateValue: rates.sellRate)
                                }

                            }.padding([.horizontal, .bottom], 10)
                            
                            
                        }
                    }
                }
                    .toolbar { //refresh button is in toolbar
                        refreshButton
                    }
                
            )
    }
    
    /**
     Button to go fetch new market data
     */
    var refreshButton: some View {
        Button {
            playerModel.hasCachedTransactions = false
            print("Refreshing from DetailView")
            Task {
                let newData = await playerModel.getMarketDataForModel()
                playerModel.cacheMarketData(newData)
            }
        } label: {
            Label("Refresh", systemImage: "arrow.triangle.2.circlepath.circle")
                .scaleEffect(1.5)
                .foregroundColor(.black)
        }
    }
    
    /**
     Buy/Sell --> profit view
     */
    struct BuySellProfit: View {
        
        let playerModel: PlayerDataModel
        let calc: Calculator = Calculator()
        
        init (model: PlayerDataModel) {
            self.playerModel = model
        }
        
        var body: some View {
            HStack (spacing: 15){
                VStack {
                    StubsText(text: "Buy: \(playerModel.best_buy_price)", spacing: 3)
                    StubsText(text: "Sell: \(playerModel.best_sell_price)", spacing: 3)
                }
                Image(systemName: "arrow.triangle.merge")
                    .scaleEffect(2.5)
                    .rotationEffect(Angle(degrees: 90.0))
                let profit = calc.flipProfit(self.playerModel)
                StubsText(text: "Profit: \(profit)", spacing: 3)
                
            }
        }
    }
    
    struct CardDetailView_Previews: PreviewProvider {
        static let testImgURL: URL = URL(string: "https://mlb21.theshow.com/rails/active_storage/blobs/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaHBBczVzIiwiZXhwIjpudWxsLCJwdXIiOiJibG9iX2lkIn19--a63051376496444a959d408eeb385c660d229548/e53423a698b7afe59590c90a70cd448d.jpg")!
        static let testModel = PlayerDataModel(name: "Test", uuid: "6a76035cf22f0d598e3d66f610d77867", bestBuy: 3000, bestSell: 9000, ovr: 99, year: 2021, shortPos: "TP", team: "Test Team", series: "Testing", imgURL: testImgURL, fromPage: 1)
        @State static var testColors: [Color] = [.orange, .black]
        static var previews: some View {
            
            CardDetailView(playerModel: testModel, gradientColors: $testColors).onAppear(perform: {
                testModel.image = Image(systemName: "photo")
            })
        }
    }
}
