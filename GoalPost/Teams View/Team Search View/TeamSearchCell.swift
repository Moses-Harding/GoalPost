//
//  TeamsSearchCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit



class TeamSearchCell: UICollectionViewCell {
    
    // MARK: Labels
    
    var teamLabel = UILabel()
    var countryLabel = UILabel()
    var checkmarkLabel: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.square.fill")
        imageView.tintColor = Colors.searchResultViewBorderColor
        imageView.isHidden = true
        return imageView
    } ()
    
    // MARK: Images
    
    var teamLogoView = UIView()
    var teamLogo = UIImageView()
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var topStack = UIStackView(.horizontal)
    var bottomStack = UIStackView(.horizontal)
    
    // MARK: Data
    
    var teamInformation: TeamObject? { didSet { updateContent() } }
    var favorite: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // 1
     func setUp() {
        
         contentView.constrain(mainStack, using: .scale, padding: 10, except: [.height], debugName: "Main Stack to Content View - Team Search Cell")
         
        mainStack.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        mainStack.layer.borderWidth = 1
        mainStack.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        mainStack.layer.cornerRadius = 5
        mainStack.backgroundColor = Colors.backgroundColor
        
        let bottomSpacer = UIView()
        
        // MARK: Set up stacks
        mainStack.add(children: [(UIView(), 0.15), (topStack, nil), (UIView(), nil), (bottomStack, 0.3), (UIView(), 0.15)])
        
        topStack.add(children: [(UIView(), 0.05), (teamLogoView, nil), (UIView(), 0.05), (teamLabel, nil), (UIView(), 0.05)])
         bottomStack.add(children: [(UIView(), 0.05), (bottomSpacer, nil), (UIView(), 0.05), (countryLabel, nil), (UIView(), 0.05), (checkmarkLabel, 0.1), (UIView(), 0.1)])
         //bottomStack.add([countryLabel])
        
        teamLabel.textColor = Colors.searchResultViewTextColor
        teamLabel.adjustsFontSizeToFitWidth = true
        countryLabel.textColor = Colors.searchResultViewSecondaryTextColor
        countryLabel.adjustsFontSizeToFitWidth = true
         
        
        teamLogoView.constrain(teamLogo, using: .scale, except: [.height], debugName: "Team Logo -> Constraint To Team Logo View")
        teamLogo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        teamLogo.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        bottomSpacer.widthAnchor.constraint(equalTo: teamLogo.widthAnchor).isActive = true
    }
    
    // 2
    func updateContent() {

        Task.init {
            
            guard let teamInformation = teamInformation else { return }
            // Set data to UI elements
            teamLabel.text = teamInformation.name + (teamInformation.national ? " (National Team)" : "")
            countryLabel.text = teamInformation.country
            
            let favorites = await Cached.data.favoriteTeams
            
            if favorites.contains { $0.key == teamInformation.id } {
                checkmarkLabel.isHidden = false
            } else {
                checkmarkLabel.isHidden = true
            }
            
            await loadImage(for: teamInformation)
        }
    }
    
    func showCheckmark() {
        self.checkmarkLabel.isHidden = false
        self.checkmarkLabel.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0) {
            self.checkmarkLabel.alpha = 1
            
        }
    }
    
    private func loadImage(for team: TeamObject) async {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = await Cached.data.retrieveImage(from: imageName) {
            
            self.teamLogo.image = image
            
            return
        }
        
        guard let url = URL(string: team.logo!) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.teamLogo.image = image
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
}


/*
 
 class TeamSearchCell: v {
     
     var teamInformation: TeamObject?
     
     override func updateConfiguration(using state: UICellConfigurationState) {
         
         // Create background configuration for cell
         var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
         backgroundConfiguration.backgroundColor = .clear
         self.backgroundConfiguration = backgroundConfiguration
         
         // Create new configuration object and update it base on state
         var newConfiguration = TeamSearchContentConfiguration().updated(for: state)
         
         // Update any configuration parameters related to data item
         newConfiguration.teamInformation = teamInformation
         
         // Set content configuration in order to update custom content view
         contentConfiguration = newConfiguration
     }
     
 }


 struct TeamSearchContentConfiguration: UIContentConfiguration, Hashable {
     
     var teamInformation: TeamObject?
     
     func makeContentView() -> UIView & UIContentView {
         return TeamSearchContentView(configuration: self)
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


 class TeamSearchContentView: UIView, UIContentView {
     
     // MARK: Labels
     
     var teamLabel = UILabel()
     var countryLabel = UILabel()
     
     // MARK: Images
     
     var teamLogoView = UIView()
     var teamLogo = UIImageView()
     
     // MARK: Views
     
     var mainStack = UIStackView(.vertical)
     
     var topStack = UIStackView(.horizontal)
     var bottomStack = UIStackView(.horizontal)
     
     private var currentConfiguration: TeamSearchContentConfiguration!
     
     //Allows easy application of a new configuration or retrieval of existing configuration
     var configuration: UIContentConfiguration {
         get {
             currentConfiguration
         }
         set {
             // Make sure the given configuration is correct type
             guard let newConfiguration = newValue as? TeamSearchContentConfiguration else {
                 return
             }
             
             // Apply the new configuration to SFSymbolVerticalContentView
             // also update currentConfiguration to newConfiguration
             apply(configuration: newConfiguration)
         }
     }
     
     
     init(configuration: TeamSearchContentConfiguration) {
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

 private extension TeamSearchContentView {
     
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
         mainStack.backgroundColor = Colors.backgroundColor
         
         let bottomSpacer = UIView()
         
         // MARK: Set up stacks
         mainStack.add(children: [(UIView(), 0.15), (topStack, nil), (UIView(), nil), (bottomStack, 0.3), (UIView(), 0.15)])
         
         topStack.add(children: [(UIView(), 0.05), (teamLogoView, nil), (UIView(), 0.05), (teamLabel, nil), (UIView(), 0.05)])
         bottomStack.add(children: [(UIView(), 0.05), (bottomSpacer, nil), (UIView(), 0.05), (countryLabel, nil), (UIView(), 0.05)])
         
         teamLabel.textColor = Colors.searchResultViewTextColor
         teamLabel.adjustsFontSizeToFitWidth = true
         countryLabel.textColor = Colors.searchResultViewSecondaryTextColor
         countryLabel.adjustsFontSizeToFitWidth = true
         
         teamLogoView.constrain(teamLogo, using: .scale, except: [.height], debugName: "Team Logo -> Constraint To Team Logo View")
         teamLogo.heightAnchor.constraint(equalToConstant: 20).isActive = true
         teamLogo.widthAnchor.constraint(equalToConstant: 20).isActive = true
         
         bottomSpacer.widthAnchor.constraint(equalTo: teamLogo.widthAnchor).isActive = true
     }
     
     private func apply(configuration: TeamSearchContentConfiguration) {
         
         // Only apply configuration if new configuration and current configuration are not the same
         guard currentConfiguration != configuration, let teamInformation = configuration.teamInformation else {
             return
         }
         
         Task.init {
             // Replace current configuration with new configuration
             currentConfiguration = configuration
             
             // Set data to UI elements
             teamLabel.text = teamInformation.name + (teamInformation.national ? " (National Team)" : "")
             countryLabel.text = teamInformation.country
             
             await loadImage(for: teamInformation)
         }
     }
     
     private func loadImage(for team: TeamObject) async {
         
         let imageName = "\(team.name) - \(team.id).png"
         
         if let image = await Cached.data.retrieveImage(from: imageName) {
             
             self.teamLogo.image = image
             
             return
         }
         
         guard let url = URL(string: team.logo!) else { return }
         
         DispatchQueue.global().async {
             if let data = try? Data(contentsOf: url) {
                 DispatchQueue.main.async {
                     
                     guard let image = UIImage(data: data) else { return }
                     
                     self.teamLogo.image = image
                     
                     Task.init {
                         await Cached.data.save(image: image, uniqueName: imageName)
                     }
                 }
             }
         }
     }
 }

 class TeamSearchCell: UICollectionViewListCell {
     
     var teamInformation: TeamObject?
     
     override func updateConfiguration(using state: UICellConfigurationState) {
         
         // Create background configuration for cell
         var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
         backgroundConfiguration.backgroundColor = .clear
         self.backgroundConfiguration = backgroundConfiguration
         
         // Create new configuration object and update it base on state
         var newConfiguration = TeamSearchContentConfiguration().updated(for: state)
         
         // Update any configuration parameters related to data item
         newConfiguration.teamInformation = teamInformation
         
         // Set content configuration in order to update custom content view
         contentConfiguration = newConfiguration
     }
     
 }


 struct TeamSearchContentConfiguration: UIContentConfiguration, Hashable {
     
     var teamInformation: TeamObject?
     
     func makeContentView() -> UIView & UIContentView {
         return TeamSearchContentView(configuration: self)
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


 class TeamSearchContentView: UIView, UIContentView {
     
     // MARK: Labels
     
     var teamLabel = UILabel()
     var countryLabel = UILabel()
     
     // MARK: Images
     
     var teamLogoView = UIView()
     var teamLogo = UIImageView()
     
     // MARK: Views
     
     var mainStack = UIStackView(.vertical)
     
     var topStack = UIStackView(.horizontal)
     var bottomStack = UIStackView(.horizontal)
     
     private var currentConfiguration: TeamSearchContentConfiguration!
     
     //Allows easy application of a new configuration or retrieval of existing configuration
     var configuration: UIContentConfiguration {
         get {
             currentConfiguration
         }
         set {
             // Make sure the given configuration is correct type
             guard let newConfiguration = newValue as? TeamSearchContentConfiguration else {
                 return
             }
             
             // Apply the new configuration to SFSymbolVerticalContentView
             // also update currentConfiguration to newConfiguration
             apply(configuration: newConfiguration)
         }
     }
     
     
     init(configuration: TeamSearchContentConfiguration) {
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

 private extension TeamSearchContentView {
     
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
         mainStack.backgroundColor = Colors.backgroundColor
         
         let bottomSpacer = UIView()
         
         // MARK: Set up stacks
         mainStack.add(children: [(UIView(), 0.15), (topStack, nil), (UIView(), nil), (bottomStack, 0.3), (UIView(), 0.15)])
         
         topStack.add(children: [(UIView(), 0.05), (teamLogoView, nil), (UIView(), 0.05), (teamLabel, nil), (UIView(), 0.05)])
         bottomStack.add(children: [(UIView(), 0.05), (bottomSpacer, nil), (UIView(), 0.05), (countryLabel, nil), (UIView(), 0.05)])
         
         teamLabel.textColor = Colors.searchResultViewTextColor
         teamLabel.adjustsFontSizeToFitWidth = true
         countryLabel.textColor = Colors.searchResultViewSecondaryTextColor
         countryLabel.adjustsFontSizeToFitWidth = true
         
         teamLogoView.constrain(teamLogo, using: .scale, except: [.height], debugName: "Team Logo -> Constraint To Team Logo View")
         teamLogo.heightAnchor.constraint(equalToConstant: 20).isActive = true
         teamLogo.widthAnchor.constraint(equalToConstant: 20).isActive = true
         
         bottomSpacer.widthAnchor.constraint(equalTo: teamLogo.widthAnchor).isActive = true
     }
     
     private func apply(configuration: TeamSearchContentConfiguration) {
         
         // Only apply configuration if new configuration and current configuration are not the same
         guard currentConfiguration != configuration, let teamInformation = configuration.teamInformation else {
             return
         }
         
         Task.init {
             // Replace current configuration with new configuration
             currentConfiguration = configuration
             
             // Set data to UI elements
             teamLabel.text = teamInformation.name + (teamInformation.national ? " (National Team)" : "")
             countryLabel.text = teamInformation.country
             
             await loadImage(for: teamInformation)
         }
     }
     
     private func loadImage(for team: TeamObject) async {
         
         let imageName = "\(team.name) - \(team.id).png"
         
         if let image = await Cached.data.retrieveImage(from: imageName) {
             
             self.teamLogo.image = image
             
             return
         }
         
         guard let url = URL(string: team.logo!) else { return }
         
         DispatchQueue.global().async {
             if let data = try? Data(contentsOf: url) {
                 DispatchQueue.main.async {
                     
                     guard let image = UIImage(data: data) else { return }
                     
                     self.teamLogo.image = image
                     
                     Task.init {
                         await Cached.data.save(image: image, uniqueName: imageName)
                     }
                 }
             }
         }
     }
 }

 */
