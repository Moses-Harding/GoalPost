//
//  String.swift
//  GoalPost
//
//  Created by Moses Harding on 5/8/22.
//

import Foundation

extension String {
    
    init(_ int: Int?) {
        if let int = int {
            self.init(int)
        } else {
            self.init("")
        }
    }
    
    init(_ float: Float?) {
        if let float = float {
            self.init(float)
        } else {
            self.init("")
        }
    }
}
