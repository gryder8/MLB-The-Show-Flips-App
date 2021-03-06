//
//  StyledGradientView.swift
//  WorkoutTimer
//
//  Created by Gavin Ryder on 9/8/20.
//  Copyright © 2020 Gavin Ryder. All rights reserved.
//

import Foundation
import UIKit

extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var colorReturnded: UIColor?
        if let colorData = data(forKey: key) {
            do {
                if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                    colorReturnded = color
                }
            } catch {
                print("Error UserDefaults")
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
                print("Error UserDefaults")
            }
        }
        set(colorData, forKey: key)
    }
}

//this class is static and handles changing the app's gradient view across VCs
class StyledGradientView: GradientBackgroundView {
    public static let shared:GradientBackgroundView = GradientBackgroundView()
    public static var viewColors:[UIColor] = [.systemTeal, .blue] {
        didSet {
            setColors(colors: viewColors)
        }
    }
    static var initialized = false
    
    private static let FIRST_COLOR_KEY = "COLOR1"
    private static let SECOND_COLOR_KEY = "COLOR2"
    private static let defaults = UserDefaults.standard
    
    static func setup() {
        if (!initialized && areColorsStoredLocally()) {
            
            var foundColors:[UIColor] = []
            
            if let firstColor = defaults.colorForKey(key: FIRST_COLOR_KEY) {
                foundColors.append(firstColor)
            } else {
                print("***COULD NOT FIND FIRST COLOR***")
                //initialized = true
            }
            
            if let secondColor = defaults.colorForKey(key: SECOND_COLOR_KEY) {
                foundColors.append(secondColor)
            } else {
                print("***COULD NOT FIND SECOND COLOR***")
            }
            //print(foundColors)
            self.viewColors = foundColors
            initialized = true
        } else {
            setColors(colors: viewColors)
            initialized = true
        }
    }
    
    static private func areColorsStoredLocally() -> Bool {
        let stored:Bool = (defaults.colorForKey(key: FIRST_COLOR_KEY) != nil || defaults.colorForKey(key: SECOND_COLOR_KEY) != nil)
        print("Colors Stored: \(stored)")
        return stored
    }
    
    
    static func setColors(colors: [UIColor]) {
        //do {
        defaults.setColor(color: viewColors[0], forKey: FIRST_COLOR_KEY)
        defaults.setColor(color: viewColors[1], forKey: SECOND_COLOR_KEY)
        //    } catch {
        //        print("***FAILED TO SAVE COLORS***")
        //    }
    }
    
    static func setColorsForGradientView(view: GradientBackgroundView) {
        view.startColor = viewColors[0]
        view.endColor = viewColors[1]
    }
}
