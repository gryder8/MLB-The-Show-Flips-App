//
//  AppearanceController.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/6/22.
//

import SwiftUI

struct AppearanceController: View {
    
    @Binding var gradientColors: [Color]
    
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
            .overlay(
                VStack{
                    ColorPicker("First Gradient Color", selection: $gradientColors[0])
                        .padding(.horizontal, 100)
                        .scaleEffect(1.2)
                    swapButton
                    ColorPicker("Second Gradient Color", selection: $gradientColors[1])
                        .padding(.horizontal, 100)
                        .scaleEffect(1.2)
                    
                }
            )
    }
    
    private var swapButton: some View {
        
        Button {
            let temp = gradientColors[0]
            gradientColors[0] = gradientColors[1]
            gradientColors[1] = temp
        } label: {
            SmallSystemImageButton(sysName: "arrow.up.arrow.down")
            
        }
    }
}

struct AppearanceController_Previews: PreviewProvider {
    @State static var testColors: [Color] = [.orange, .black]
    static var previews: some View {
        AppearanceController(gradientColors: $testColors)
    }
}
