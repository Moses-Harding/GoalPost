//
//  FixtureCellContentView.swift
//  GoalPost
//
//  Created by Moses Harding on 4/28/22.
//

import Foundation
import UIKit

class FixtureCellContentView: UIView, UIContentView {
    
    //MARK: Labels
    
    var homeTeamLabel = UILabel()
    var awayTeamLabel = UILabel()
    var homeTeamScore = UILabel()
    var awayTeamScore = UILabel()
    var vsLabel = UILabel()
    
    var allLabels: [UILabel] {
        return [homeTeamLabel, awayTeamLabel, homeTeamScore, awayTeamScore, vsLabel]
    }
    
    //MARK: Views
    
    var verticalStack = UIStackView(.vertical)
    var mainStack = UIStackView(.horizontal)
    var imageStack = UIStackView(.horizontal)
    var labelStack = UIStackView(.vertical)
    var homeTeamStack = UIStackView(.horizontal)
    var awayTeamStack = UIStackView(.horizontal)
    
    var homeImageView = UIImageView()
    var awayImageView = UIImageView()
    
    //MARK: Lines
    
    var line = UIView()

    private var currentConfiguration: FixtureCellContentConfiguration!
    
    //Allows easy application of a new configuration or retrieval of existing configuration
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            // Make sure the given configuration is correct type
            guard let newConfiguration = newValue as? FixtureCellContentConfiguration else {
                return
            }
            
            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }
    

    init(configuration: FixtureCellContentConfiguration) {
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

private extension FixtureCellContentView {
    
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
        mainStack.add(children: [(imageStack, nil), (UIView(), nil), (labelStack, 0.7)])
        imageStack.add(children: [(UIView(), nil), (homeImageView, 0.3), (UIView(), 0.05), (vsLabel, 0.05), (UIView(), 0.05), (awayImageView, 0.3), (UIView(), nil)])
        //mainStack.add(children: [(UIView(), nil), (homeImageView, nil), (UIView(), nil), (vsLabel, nil), (UIView(), nil), (awayImageView, nil), (UIView(), nil), (labelStack, 0.7)])
        labelStack.add([homeTeamStack, awayTeamStack])
        homeTeamStack.add(children: [(homeTeamLabel, 0.9), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayTeamLabel, 0.9), (awayTeamScore, nil)])
        
        // MARK: Format labels
        allLabels.forEach { $0.textColor = .black }
        
        // MARK: Set up image stack
        homeImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        homeImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        
        awayImageView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        awayImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        
        imageStack.alignment = .center
    }
    
    private func apply(configuration: FixtureCellContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration, let fixture = configuration.fixture else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Set data to UI elements
        homeTeamLabel.text = fixture.homeTeam.name
        homeTeamScore.text = String(fixture.homeTeam.score)
        awayTeamLabel.text = fixture.awayTeam.name
        awayTeamScore.text = String(fixture.awayTeam.score)
        
        vsLabel.text = "-"
        vsLabel.sizeToFit()
        imageStack.layoutSubviews()
        
        /*TEST DATA*/
        
        homeImageView.image = UIImage(named: "Default Home Icon")
        awayImageView.image = UIImage(named: "Default Away Icon")
    }
}
