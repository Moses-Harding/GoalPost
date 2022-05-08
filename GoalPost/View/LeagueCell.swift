//
//  LeagueCell.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class LeagueCell: UICollectionViewListCell {
    
    var league: LeagueData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create background configuration for cell
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = Colors.darkColor
        //backgroundConfiguration.backgroundInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 0, trailing: 2)
        self.backgroundConfiguration = backgroundConfiguration
            
        // Create new configuration object and update it base on state
        var newConfiguration = LeagueCellContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.league = league

        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}
