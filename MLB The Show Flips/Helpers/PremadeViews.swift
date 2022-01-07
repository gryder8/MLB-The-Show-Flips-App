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
