//
//  Constants.swift
//  GoalPost
//
//  Created by Moses Harding on 5/4/22.
//

import Foundation
import UIKit

struct Colors {
    static var blue = BlueColors()
    static var gray = GrayColors()
    static var green = GreenColors()
    static var orange = OrangeColors()
    static var purple = PurpleColors()
    static var red = RedColors()
    static var yellow = YellowColors()
    static var brown = BrownColors()
    static var pink = PinkColors()
    static var white = WhiteColors()
    
    static var backgroundColor = UIColor.black //gray.hex121310
    
    static var titleAreaColor = gray.hex1C1F1C
    static var titleAreaTextColor = green.hex18EE88
    
    static var headerColor = gray.hex1C1F1C
    static var headerTextColor = green.hex18EE88
    
    static var cellBodyColor = gray.hex282B28
    static var cellBodyTextColor = white.hexFFFCF9

    static var searchResultViewBackgroundColor = gray.hex1C1F1C
    static var searchResultViewBorderColor = green.hex18EE88
    static var searchResultViewTextColor = white.hexFFFCF9
    static var searchResultViewSecondaryTextColor = green.hex5C996C
    
    static var cellBackgroundGray = gray.hex1C1F1C
    static var cellSecondaryTextColor = green.hex5C996C
    static var cellHighlightedBackgroundColor = gray.hex4A5759Alpha//green.hex5C996CAlpha

    static var removalButtonBackgroundColor = red.hexFC7168
    static var removalButtonBorderColor = red.hexFE5F55

    static var cellBorderGreen = green.hexA0F8CD
    static var cellTextGreen = green.hexA0F8CD
    
    static var addButtonBackgroundColor = gray.hex1C1F1C
    static var addButtonTextColor = white.hexFFFCF9
    static var addButtonBorderColor = green.hex18EE88
    
    static var statusRed = red.hexFE5F55
    
    static var primaryGreen = green.hex18EE88
    static var secondaryGreen = green.hex5C996C

}

struct GreenColors {
    var hex18EE88 = UIColor(red: 0.09, green: 0.93, blue: 0.53, alpha: 1.00)
    var hex5C996C = UIColor(red: 0.36, green: 0.60, blue: 0.42, alpha: 1.00)
    var hex5C996CAlpha = UIColor(red: 0.36, green: 0.60, blue: 0.42, alpha: 0.2)
    var hexD9FCEB = UIColor(red: 0.85, green: 0.99, blue: 0.92, alpha: 1.00)
    //var hexECFDF5 = UIColor(red: 0.93, green: 0.99, blue: 0.96, alpha: 1.00)
    //var hex99EDCC = UIColor(red: 0.60, green: 0.93, blue: 0.80, alpha: 1.00)
    //var hexA8F0D3 = UIColor(red: 0.66, green: 0.94, blue: 0.83, alpha: 1.00)
    var hex67F4B0 = UIColor(red: 0.40, green: 0.96, blue: 0.69, alpha: 1.00)
    var hexA0F8CD = UIColor(red: 0.63, green: 0.97, blue: 0.80, alpha: 1.00)
}

struct OrangeColors {
    
}

struct BlueColors {
    //var hexB7CECE = UIColor(red: 0.72, green: 0.81, blue: 0.81, alpha: 1.00)
    //var hex247BA0 = UIColor(red: 0.14, green: 0.48, blue: 0.63, alpha: 1.00)
}

struct GrayColors {
    var hex282B28 = UIColor(red: 0.16, green: 0.17, blue: 0.16, alpha: 1.00)
    var hex1C1F1C = UIColor(red: 0.11, green: 0.12, blue: 0.11, alpha: 1.00)
    var hex313531 = UIColor(red: 0.19, green: 0.21, blue: 0.19, alpha: 1.00)
    //var hexCACECA = UIColor(red: 0.79, green: 0.81, blue: 0.79, alpha: 1.00)
    var hex4A5759 = UIColor(red: 0.29, green: 0.34, blue: 0.35, alpha: 1.00)
    var hex4A5759Alpha = UIColor(red: 0.29, green: 0.34, blue: 0.35, alpha: 0.35)
    //var hexF7F5F5 = UIColor(red: 0.97, green: 0.96, blue: 0.96, alpha: 1.00)
}

struct PurpleColors {
    //var hex450C49 = UIColor(red: 0.27, green: 0.05, blue: 0.29, alpha: 1.00)
    //var hexE1E5F2 = UIColor(red: 0.88, green: 0.90, blue: 0.95, alpha: 1.00)
    //var hexB9C0DA = UIColor(red: 0.73, green: 0.75, blue: 0.85, alpha: 1.00)
}

struct RedColors {
    var hexFE5F55 = UIColor(red: 1.00, green: 0.37, blue: 0.33, alpha: 1.00)
    var hexFC7168 = UIColor(red: 0.99, green: 0.44, blue: 0.41, alpha: 0.1)
    var hexB14E4E = UIColor(red: 0.69, green: 0.31, blue: 0.31, alpha: 1.00)
}

struct WhiteColors {
    var hexFFFCF9 = UIColor(red: 1.00, green: 0.99, blue: 0.98, alpha: 1.00)
}

struct YellowColors {
    //var hexF2CC8F = UIColor(red: 0.95, green: 0.80, blue: 0.56, alpha: 1.00)
}

struct BrownColors {
    //var hexB0A084 = UIColor(red: 0.69, green: 0.63, blue: 0.52, alpha: 1.00)
}

struct PinkColors {
    //var hexF7E2DE = UIColor(red: 0.97, green: 0.89, blue: 0.87, alpha: 1.00)
}
