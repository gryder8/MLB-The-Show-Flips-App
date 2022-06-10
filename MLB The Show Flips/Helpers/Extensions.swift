//
//  ColorExtension.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI

extension Array where Element: Comparable & AdditiveArithmetic & Numeric {
    func outliersRemoved() -> [Self.Element] {
        let sorted = self.sorted { x1, x2 in
            return x1 < x2
        }
        
        print("Incoming values: \(sorted)")
        
        let quartile1 = sorted[Int(floor(Double(sorted.count) * (1/4)))]
        let quartile3 = sorted[Int(ceil(Double(sorted.count) * (3/4)))]
        
        let interquartileRange = quartile3 - quartile1
        
        let maxValue = quartile3 + interquartileRange*2 //needed for conformance across generic types
        let minValue = quartile1 - interquartileRange*2
        
        let filteredValues = sorted.filter { x in
            return (x >= minValue && x <= maxValue)
        }
        print("Outgoing values: \(filteredValues)")
        
        return self.filter { element in //don't change the order
            filteredValues.contains(element)
        }
    }
}

internal extension Color {
    init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0
        )
    }

    init(hexValue: Int, a: CGFloat = 1.0) {
        self.init(
            red: (hexValue >> 16) & 0xFF,
            green: (hexValue >> 8) & 0xFF,
            blue: hexValue & 0xFF,
            a: a
        )
    }

    static func adaptive(dark: UIColor, light: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor {$0.userInterfaceStyle == .dark ? dark : light }
        } else {
            return light
        }
    }
}
