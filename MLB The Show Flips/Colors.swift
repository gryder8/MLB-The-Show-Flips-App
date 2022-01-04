//
//  Colors.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI

internal enum Colors {
    static var darkGray:Color {
        return Color(hexValue: 0x383838)
    }
    
    static var darkTeal: Color {
        return Color(hexValue: 0x008080)
    }
    
    static var darkYellow: Color {
        return Color(hexValue: 0xFFD700)
    }

    static var darkerGray: Color {
        return Color(hexValue: 0x505456)
    }
    
    static var midGray: Color {
        return Color(hexValue: 0x737373)
    }
    
    static var backgroundGradientColors: [Color] {
        return [.teal, .blue]
    }
}
