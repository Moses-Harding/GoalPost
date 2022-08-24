//
//  LeaguesCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/16/22.
//

import Foundation
import UIKit

class LeagueCollectionCell: UICollectionViewListCell {
    
    var leagueInformation: LeagueObject?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create background configuration for cell
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .clear
        self.backgroundConfiguration = backgroundConfiguration
        
        // Create new configuration object and update it base on state
        var newConfiguration = LeagueContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.leagueInformation = leagueInformation
        
        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}


struct LeagueContentConfiguration: UIContentConfiguration, Hashable {
    
    var leagueInformation: LeagueObject?
    
    func makeContentView() -> UIView & UIContentView {
        return LeagueContentView(configuration: self)
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


class LeagueContentView: UIView, UIContentView {
    
    // MARK: Labels
    
    var leagueLabel = UILabel()
    var countryLabel = UILabel()
    
    // MARK: Images
    
    var leagueLogoView = UIView()
    var leagueLogo = UIImageView()
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var topStack = UIStackView(.horizontal)
    var bottomStack = UIStackView(.horizontal)
    
    private var currentConfiguration: LeagueContentConfiguration!
    
    //Allows easy application of a new configuration or retrieval of existing configuration
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            // Make sure the given configuration is correct type
            guard let newConfiguration = newValue as? LeagueContentConfiguration else {
                return
            }
            
            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }
    
    
    init(configuration: LeagueContentConfiguration) {
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

private extension LeagueContentView {
    
    private func setupAllViews() {
        
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 1),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 1),
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 1),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 1),
        ])
        
        mainStack.layer.borderWidth = 1
        mainStack.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        mainStack.layer.cornerRadius = 5
        mainStack.backgroundColor = Colors.searchResultViewBackgroundColor
        
        let bottomSpacer = UIView()
        
        // MARK: Set up stacks
        mainStack.add(children: [(UIView(), 0.15), (topStack, nil), (UIView(), nil), (bottomStack, 0.3), (UIView(), 0.15)])
        
        topStack.add(children: [(UIView(), 0.05), (leagueLogoView, nil), (UIView(), 0.05), (leagueLabel, nil), (UIView(), 0.05)])
        bottomStack.add(children: [(UIView(), 0.05), (bottomSpacer, nil), (UIView(), 0.05), (countryLabel, nil), (UIView(), 0.05)])
        
        leagueLabel.textColor = Colors.searchResultViewTextColor
        leagueLabel.adjustsFontSizeToFitWidth = true
        countryLabel.textColor = Colors.searchResultViewSecondaryTextColor
        countryLabel.adjustsFontSizeToFitWidth = true
        
        leagueLogoView.constrain(leagueLogo, using: .scale, except: [.height], debugName: "League Logo -> Constraint To League Logo View")
        leagueLogo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        leagueLogo.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        bottomSpacer.widthAnchor.constraint(equalTo: leagueLogo.widthAnchor).isActive = true
    }
    
    private func apply(configuration: LeagueContentConfiguration) {
        
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration, let leagueInformation = configuration.leagueInformation else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Set data to UI elements
        leagueLabel.text = leagueInformation.name
        countryLabel.text = leagueInformation.country
        
        loadImage(for: leagueInformation)
    }
    
    private func loadImage(for league: LeagueObject) {
        
        let imageName = "\(league.name) - \(league.id).png"
        
        Task.init {
            if let image = await Cached.data.retrieveImage(from: imageName) {
                
                self.leagueLogo.image = image
                
                return
            }
        }
        
        guard let url = URL(string: league.logo!) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.leagueLogo.image = image
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
}
