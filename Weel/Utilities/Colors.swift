//
//  Colors.swift
//  Weel
//
//  Created by Kibret Woldemichael on 3/15/25.
//

import Foundation
import SwiftUI

extension UIColor {
    static let appBackground = UIColor(hex: "F7F3F7").withAlphaComponent(0.89)
    static let appLightGray = UIColor(hex: "C9C6CD")
    static let appDarkGray = UIColor(hex: "454545")
    static let appBlue = UIColor(hex: "1E47F7")

    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light, .unspecified:
                return light
            case .dark:
                return dark
            @unknown default:
                return light
            }
        }
    }
    
    convenience init(hex: String) {
        let cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension Color {
    
    static let appBackground = Color(uiColor: .appBackground)
    static let appLightGray = Color(uiColor: .appLightGray)
    static let appDarkGray = Color(uiColor: .appDarkGray)
    static let appBlue = Color(uiColor: .appBlue)
    
    // MARK: - Background Colors
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(uiColor: UIColor.secondarySystemBackground)
    static let tertiarySystemBackground = Color(uiColor: UIColor.tertiarySystemBackground)
    
    init(light: Color, dark: Color) {
        self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
    }
    
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        
        let length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
            
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}
