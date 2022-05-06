//
//  LeagueCellContentConfiguration.swift
//  GoalPost
//
//  Created by Moses Harding on 4/28/22.
//

import Foundation
import UIKit

struct LeagueCellContentConfiguration: UIContentConfiguration, Hashable {
    
    var league: LeagueData?
    
    func makeContentView() -> UIView & UIContentView {
        return LeagueCellContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
        // Perform update on parameters that are not related to cell's data itesm
        
        // Make sure we are dealing with instance of UICellConfigurationState
        guard let state = state as? UICellConfigurationState else {
            return self
        }
        
        // Updater self based on the current state
        var updatedConfiguration = self
        
        if state.isSelected {
            // Selected state
        } else {
            // Other states
        }

        return updatedConfiguration
    }
    
}
