//
//  LeagueCell.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class LeagueCell: UICollectionViewListCell {
    
    var league: MatchLeagueData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create background configuration for cell
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = Colors.headerColor
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

struct LeagueCellContentConfiguration: UIContentConfiguration, Hashable {
    
    var league: MatchLeagueData?
    
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

class LeagueCellContentView: UIView, UIContentView {
    
    //MARK: Labels
    
    var leagueLabel = UILabel()
    
    //MARK: Views

    var mainStack = UIStackView(.horizontal)

    private var currentConfiguration: LeagueCellContentConfiguration!
    
    //Allows easy application of a new configuration or retrieval of existing configuration
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            // Make sure the given configuration is correct type
            guard let newConfiguration = newValue as? LeagueCellContentConfiguration else {
                return
            }
            
            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }
    

    init(configuration: LeagueCellContentConfiguration) {
        super.init(frame: .zero)
        
        // Create the content view UI
        setupAllViews()

        
        // Apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension LeagueCellContentView {
    
    private func setupAllViews() {

        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
        
        
        // MARK: Set up stacks
        mainStack.addArrangedSubview(leagueLabel)
        leagueLabel.textAlignment = .center
        leagueLabel.textColor = Colors.headerTextColor
        leagueLabel.font = UIFont.boldSystemFont(ofSize: 16)

        
    }
    
    private func apply(configuration: LeagueCellContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration, let league = configuration.league else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Set data to UI elements
        leagueLabel.text = league.id != FavoriteTeamLeague.identifer.rawValue ? league.name + " - " + league.country : league.name
    }
}
