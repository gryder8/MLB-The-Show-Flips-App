//
//  CardDetailView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/7/22.
//

import SwiftUI

//https://github.com/AppPear/ChartView/
//https://github.com/aunnnn/MovingNumbersView

//use initial observable model approach to load item data into the view

struct CardDetailView: View {
    
    
    //@ObservedObject var itemDataSource: ItemDataSource
    
    let urlBaseString = "https://mlb21.theshow.com/items/"
    
    //let url: URL
    @Binding var playerModel: PlayerDataModel
    //var playerItem: PlayerItem
    //let playerListing: PlayerListing
    let calc:Calculator = Calculator()
    @Binding var gradientColors: [Color]
    
    init(playerModel: PlayerDataModel, gradColors: [Color]) {
        //        self.playerListing = playerListing
        //        self.playerItem = playerListing.item
        //        self.url = playerListing.item.img
        //        Task.init {
        //            await playerModel.cacheMarketTransactionData()
        //            //await playerModel.cacheImage()
        //        }
        _playerModel = Binding.constant(playerModel)
        _gradientColors = Binding.constant(gradColors)
    }
    
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
    
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                ScrollView {
                    //let marketListing = itemDataSource.marketListing
                    //let playerListing = itemDataSource.marketListing.playerListing
                    //let playerItem = itemDataSource.marketListing.playerListing.item
                    if (playerModel.isFetching) {
                        ProgressView()
                            .progressViewStyle(DarkBlueShadowProgressViewStyle())
                            .scaleEffect(1.5, anchor: .center)
                            .frame(width: 40, height: 40)
                    }
                    VStack { //top level
                        VStack(alignment: .center) { //centering V-Stack for the player img, name and subtitle info
                            
                            playerModel.image
                            
                            //Text(marketListing.completed_orders[0].date)
                            
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
                        
                    }
                }
            )
    }
}

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
    static var testColors: [Color] = [.orange, .black]
    static var previews: some View {
        
        CardDetailView(playerModel: testModel, gradColors: testColors).onAppear(perform: {
            testModel.image = Image(systemName: "photo")
        })
    }
}
