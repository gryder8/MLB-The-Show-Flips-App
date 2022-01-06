//
//  BackgroundGradientView.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/5/22.
//

import SwiftUI



struct BackgroundGradientView: View {
    @State var gradientColors:[Color] = [.teal, .blue]
    var body: some View {
        LinearGradient(colors: gradientColors, startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.vertical)
    }
}

struct BackgroundGradientView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundGradientView()
    }
}

