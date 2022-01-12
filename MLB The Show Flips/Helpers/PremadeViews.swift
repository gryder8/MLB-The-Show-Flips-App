//
//  ButtonStyles.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/7/22.
//

import SwiftUI

struct SmallSystemImageButton: View {
    var systemName = ""
    init(sysName: String) {
        self.systemName = sysName
    }
    
    var body: some View {
        Image(systemName: self.systemName)
            .frame(width: 40, height: 40, alignment: .center)
            .foregroundColor(.black)
        //.background(.red)
            .cornerRadius(8)
            .buttonStyle(.bordered)
    }
    
}

struct PlayerAsyncImage: View {
    var playerImgUrl: URL
    
    init(imgURL: URL) {
        self.playerImgUrl = imgURL
    }
    
    var body: some View {
        AsyncImage(url: playerImgUrl, transaction: Transaction(animation: .easeInOut)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .progressViewStyle(DarkBlueShadowProgressViewStyle())
                    .scaleEffect(1.5, anchor: .center)
            case .success(let image):
                image
                    .fixedSize(horizontal: true, vertical: true)
            case .failure:
                Image(systemName: "person.crop.circle.badge.exclamationmark")
                    .scaleEffect(3.5)
                    .padding(.bottom, 10)
                    .foregroundColor(.red)
            @unknown default:
                EmptyView()
            }
        }
    }
}

struct StubsText: View {
    var spacing: CGFloat
    var text: String
    
    init(text: String, spacing: CGFloat = 0) {
        self.spacing = spacing
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: self.spacing) {
            Text(self.text)
            StubSymbol()
        }
    }
}
