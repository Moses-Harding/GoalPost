//
//  FixtureCell.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class FixtureCell: UICollectionViewListCell {
    
    var fixture: FixtureData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Remove gray background when selected:
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .white
        //backgroundConfiguration.cornerRadius = 0
        //backgroundConfiguration.strokeColor = .black
        //backgroundConfiguration.strokeWidth = 1
        //backgroundConfiguration.backgroundInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2)
        self.backgroundConfiguration = backgroundConfiguration
            
        // Create new configuration object and update it base on state
        var newConfiguration = FixtureCellContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.fixture = fixture

        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}
