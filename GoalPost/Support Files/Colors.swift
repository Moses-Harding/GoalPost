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
    
    static var darkColor = purple.hex450C49
    static var lightColor = green.hex18EE88
}

struct GreenColors {
    var hex7AE7C7 = UIColor(red: 0.48, green: 0.91, blue: 0.78, alpha: 1.00)
    var hex18EE88 = UIColor(red: 0.09, green: 0.93, blue: 0.53, alpha: 1.00)
}

struct OrangeColors {
    
}

struct BlueColors {
}

struct GrayColors {

}

struct PurpleColors {
    var hex450C49 = UIColor(red: 0.27, green: 0.05, blue: 0.29, alpha: 1.00)
}
