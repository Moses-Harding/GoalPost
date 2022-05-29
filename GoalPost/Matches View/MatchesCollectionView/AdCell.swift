//
//  AdCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/17/22.
//

import Foundation
import UIKit

class AdCell: UICollectionViewListCell {
    
    var ad: AdData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create background configuration for cell
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = .clear
        //backgroundConfiguration.backgroundInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 0, trailing: 2)
        self.backgroundConfiguration = backgroundConfiguration
            
        // Create new configuration object and update it base on state
        var newConfiguration = AdCellContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.ad = ad

        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}



struct AdCellContentConfiguration: UIContentConfiguration, Hashable {
    
    var ad: AdData?
    
    func makeContentView() -> UIView & UIContentView {
        return AdCellContentView(configuration: self)
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


class AdCellContentView: UIView, UIContentView {
    
    //MARK: Labels
    
    var adLabel = UILabel()
    var adView = UIView()
    
    //MARK: Views

    var mainStack = UIStackView(.horizontal)

    private var currentConfiguration: AdCellContentConfiguration!
    
    //Allows easy application of a new configuration or retrieval of existing configuration
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            // Make sure the given configuration is correct type
            guard let newConfiguration = newValue as? AdCellContentConfiguration else {
                return
            }
            
            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }
    

    init(configuration: AdCellContentConfiguration) {
        super.init(frame: .zero)
        
        // Create the content view UI
        setupAllViews()

        
        // Apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupAllViews() {
        
        self.constrain(mainStack)
        
        mainStack.add([adView])
        
        adView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func apply(configuration: AdCellContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration, let ad = configuration.ad else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Set data to UI elements
        
        guard let bannerView = GAD.helper.bannerViews[ad.adViewName] else { fatalError("\(ad.adViewName) was not initialized") }

        adView.constrain(bannerView, using: .scale, except: [.width, .height])
        bannerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        bannerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 320).isActive = true

        GAD.helper.loadBannerAd(for: ad.adViewName, with: nil)
    }
}
