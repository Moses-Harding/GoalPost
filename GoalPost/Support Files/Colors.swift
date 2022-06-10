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
    static var white = WhiteColors()
    
    static var backgroundColor = UIColor.black //gray.hex121310
    
    static var titleAreaColor = gray.hex1C1F1C
    static var titleAreaTextColor = green.hex18EE88 // green.hex5C996C
    
    static var headerColor = gray.hex1C1F1C // green.hex395E43
    static var headerTextColor = green.hex18EE88  // white.hexFFFCF9
    
    static var cellBodyColor = gray.hex282B28
    static var cellBodyTextColor = white.hexFFFCF9
    
    static var logoTheme = green.hex18EE88
    
    //static var searchResultView = white.hexFFFCF9
    static var searchResultViewBackgroundColor = gray.hex1C1F1C
    static var searchResultViewBorderColor = green.hex18EE88
    static var searchResultViewTextColor = white.hexFFFCF9
    static var searchResultViewSecondaryTextColor = green.hex5C996C
    
    static var teamCellViewBackgroundColor = gray.hex1C1F1C
    static var teamCellViewBorderColor = green.hex18EE88
    static var teamCellViewTextColor = white.hexFFFCF9
    static var teamCellViewSecondaryTextColor = green.hex5C996C
    static var teamCellViewTertiaryTextColor = UIColor.lightGray
    static var teamCellRemovalButtonBackgroundColor = red.hexFE5F55
    
    static var teamDataStackBackgroundColor = gray.hex282B28
    static var teamDataStackTextColor = white.hexFFFCF9
    static var teamDataStackCellBackgroundColor = gray.hex313531
    static var teamDataStackCellTextColor = white.hexFFFCF9
    
    static var addButtonBackgroundColor = gray.hex1C1F1C
    static var addButtonTextColor = white.hexFFFCF9
    static var addButtonBorderColor = green.hex18EE88
    
    static var statusRed = red.hexFE5F55
    static var statusGreen = green.hex5C996C
}

struct GreenColors {
    var hex18EE88 = UIColor(red: 0.09, green: 0.93, blue: 0.53, alpha: 1.00)
    var hex5C996C = UIColor(red: 0.36, green: 0.60, blue: 0.42, alpha: 1.00)
}

struct OrangeColors {
    
}

struct BlueColors {
}

struct GrayColors {
    var hex282B28 = UIColor(red: 0.16, green: 0.17, blue: 0.16, alpha: 1.00)
    var hex1C1F1C = UIColor(red: 0.11, green: 0.12, blue: 0.11, alpha: 1.00)
    var hex313531 = UIColor(red: 0.19, green: 0.21, blue: 0.19, alpha: 1.00)
}

struct PurpleColors {
    //var hex450C49 = UIColor(red: 0.27, green: 0.05, blue: 0.29, alpha: 1.00)
}

struct RedColors {
    var hexFE5F55 = UIColor(red: 1.00, green: 0.37, blue: 0.33, alpha: 1.00)
}

struct WhiteColors {
    var hexFFFCF9 = UIColor(red: 1.00, green: 0.99, blue: 0.98, alpha: 1.00)
}
