//
//  Colors.swift
//  MLB The Show Flips
//
//  Created by Gavin Ryder on 1/2/22.
//

import SwiftUI
import SwiftUICharts

extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var colorReturnded: UIColor?
        if let colorData = data(forKey: key) {
            do {
                if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                    colorReturnded = color
                }
            } catch {
                print("Error UserDefaults: \(error.localizedDescription)")
            }
        }
        return colorReturnded
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
                colorData = data
            } catch {
                print("Error UserDefaults: \(error.localizedDescription)")
            }
        }
        set(colorData, forKey: key)
        print("\(String(describing: color?.accessibilityName)) was stored locally")
    }
}

internal enum Colors {
    //MARK: - Custom Colors
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
    
    static var UIteal: UIColor {
        return UIColor(Color.teal)
    }
    
    static var midGray: Color {
        return Color(hexValue: 0x737373)
    }
    
    static var glacier: Color {
        return Color(hexValue: 0x6ac2d4)
    }
    
    static var pastelGreen: Color {
        return Color(hexValue: 0x7dbd76)
    }
    
    static var whiteSmoke: Color {
        return Color(hexValue: 0xF5F5F5)
    }
    
    static var darkRed: Color {
        return Color(hexValue: 0xB80000)
    }
    
    private static let FIRST_COLOR_KEY = "COLOR1"
    private static let SECOND_COLOR_KEY = "COLOR2"
    private static let defaults = UserDefaults.standard
    
    static private func areColorsStoredLocally() -> Bool {
        let stored:Bool = (defaults.colorForKey(key: FIRST_COLOR_KEY) != nil || defaults.colorForKey(key: SECOND_COLOR_KEY) != nil)
        print("Colors Stored: \(stored)")
        return stored
    }
    
    static func setColorsInStorage(colors: [Color]) {
        //print(defaults.description)
        if colors.count >= 2 {
            defaults.setColor(color: UIColor(colors.first!), forKey: FIRST_COLOR_KEY)
            defaults.setColor(color: UIColor(colors.last!), forKey: SECOND_COLOR_KEY)
        }
    }
    
    private static let defaultViewColors:[Color] = [.teal, .blue]

    
    //MARK: - Color Arrays
    static var backgroundGradientColors: [Color]  {
        if (areColorsStoredLocally()) {
            var foundColors: [Color] = []
            
            if let firstColor = defaults.colorForKey(key: FIRST_COLOR_KEY) {
                foundColors.append(Color(firstColor))
                print("***FOUND FIRST COLOR")
            } else {
                print("***COULD NOT FIND FIRST COLOR***")
            }
            
            if let secondColor = defaults.colorForKey(key: SECOND_COLOR_KEY) {
                foundColors.append(Color(secondColor))
                print("***FOUND SECOND COLOR")
            } else {
                print("***COULD NOT FIND SECOND COLOR***")
            }
            
            return foundColors.count == 2 ? foundColors : defaultViewColors
        } else {
            setColorsInStorage(colors: defaultViewColors)
            return defaultViewColors
        }
        
    }
}
