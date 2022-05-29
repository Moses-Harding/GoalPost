//
//  TeamsCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/16/22.
//

import Foundation
import UIKit

/*
class TeamCollectionCell: UICollectionViewListCell {
    
    var teamInformation: TeamSearchData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create background configuration for cell
        //var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        //backgroundConfiguration.backgroundColor = .clear
        //self.backgroundConfiguration = backgroundConfiguration
            
        // Create new configuration object and update it base on state
        var newConfiguration = TeamContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.teamInformation = teamInformation
        
        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}


struct TeamContentConfiguration: UIContentConfiguration, Hashable {
    
    var teamInformation: TeamSearchData?
    
    func makeContentView() -> UIView & UIContentView {
        return TeamContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
        // Perform update on parameters that are not related to cell's data itesm
        
        // Make sure we are dealing with instance of UICellConfigurationState
        guard let state = state as? UICellConfigurationState else {
            return self
        }
        
        // Update self based on the current state
        var updatedConfiguration = self
        if state.isSelected {
            // Selected state
        } else {
            // Other states
        }

        return updatedConfiguration
    }
    
}


class TeamContentView: UIView, UIContentView {
    
    // MARK: Labels

    var teamLabel = UILabel()
    var tapForMoreLabel = UILabel()
    var countryLabel = UILabel()
    
    // MARK: Images
    
    var teamLogoView = UIView()
    var teamLogo = UIImageView()
    
    // MARK: Views

    var mainStack = UIStackView(.vertical)
    
    var topStack = UIStackView(.horizontal)
    var bottomStack = UIStackView(.horizontal)
    
    var teamDataView = UIView()

    private var currentConfiguration: TeamContentConfiguration!
    
    //Allows easy application of a new configuration or retrieval of existing configuration
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            // Make sure the given configuration is correct type
            guard let newConfiguration = newValue as? TeamContentConfiguration else {
                return
            }
            
            // Apply the new configuration to SFSymbolVerticalContentView
            // also update currentConfiguration to newConfiguration
            apply(configuration: newConfiguration)
        }
    }
    

    init(configuration: TeamContentConfiguration) {
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

        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 1),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: 1),
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: 1),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: 1),
        ])
        
        mainStack.layer.borderWidth = 1
        mainStack.layer.borderColor = Colors.teamCellViewBorderColor.cgColor
        mainStack.layer.cornerRadius = 5
        mainStack.backgroundColor = Colors.teamCellViewBackgroundColor
        
        let bottomSpacer = UIView()
        
        // MARK: Set up stacks
        mainStack.add(children: [(UIView(), 0.15), (topStack, nil), (UIView(), nil), (bottomStack, 0.3), (UIView(), 0.15)])
        
        topStack.add(children: [(UIView(), 0.05), (teamLogoView, nil), (UIView(), 0.05), (teamLabel, nil), (UIView(), 0.05), (tapForMoreLabel, nil), (UIView(), 0.05)])
        bottomStack.add(children: [(UIView(), 0.05), (bottomSpacer, nil), (UIView(), 0.05), (countryLabel, nil), (UIView(), 0.05)])
        
        teamLabel.textColor = Colors.teamCellViewTextColor
        teamLabel.adjustsFontSizeToFitWidth = true
        
        countryLabel.textColor = Colors.teamCellViewSecondaryTextColor
        countryLabel.adjustsFontSizeToFitWidth = true
        
        tapForMoreLabel.textColor = Colors.teamCellViewTertiaryTextColor
        tapForMoreLabel.adjustsFontSizeToFitWidth = true
        
        teamLogoView.constrain(teamLogo, using: .scale, except: [.height], debugName: "Team Logo -> Constraint To Team Logo View")
        teamLogo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        teamLogo.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        bottomSpacer.widthAnchor.constraint(equalTo: teamLogo.widthAnchor).isActive = true
    }
    
    private func apply(configuration: TeamContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration, let teamInformation = configuration.teamInformation else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        tapForMoreLabel.text = "Tap for more..."
        teamLabel.text = teamInformation.name + (teamInformation.national ? " (National Team)" : "")
        countryLabel.text = teamInformation.country
        
        loadImage(for: teamInformation)
    }
    
    private func loadImage(for team: TeamSearchData) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            self.teamLogo.image = image
            
            return
        }
        
        guard let url = URL(string: team.logo!) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.teamLogo.image = image
                    
                    Cached.data.save(image: image, uniqueName: imageName)
                }
            }
        }
    }
}
*/


class TeamCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamInformation: TeamSearchData? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    
    // Views
    private let logoArea = UIView()
    let nameArea = UIView()
    
    // Labels
    private let nameLabel = UILabel()
    private let foundedLabel = UILabel()
    private let countryLabel = UILabel()
    private let codeLabel = UILabel()
    private let nationalLabel = UILabel()
    
    // Image
    private let teamLogo = UIImageView()
    
    // Stacks
    private lazy var nameStack = UIStackView(.horizontal)
    private lazy var mainStack = UIStackView(.vertical)
    private lazy var labelStack = UIStackView(.vertical)
    
    // Constraints
    private var closedConstraint: NSLayoutConstraint?
    private var openConstraint: NSLayoutConstraint?
    
    // Layout
    private let padding: CGFloat = 8
    private let cornerRadius: CGFloat = 8
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    
    private func setUp() {
        backgroundColor = .systemGray6
        clipsToBounds = true
        layer.cornerRadius = cornerRadius

        setUpMainStack()
        setUpTitleArea()
        setUpConstraints()
        updateAppearance()
    }
    
    private func setUpMainStack() {
        
        contentView.constrain(mainStack, using: .edges, padding: 5, except: [.bottom])
        mainStack.add([nameStack, labelStack])
        
        labelStack.add([countryLabel, foundedLabel, codeLabel, nationalLabel])
    }
    
    func setUpTitleArea() {
        //nameStack.backgroundColor = .green
        
        nameStack.add(children: [(nameArea, 0.7), (UIView(), nil), (logoArea, nil)])
        nameStack.alignment = .center
        
        nameArea.constrain(nameLabel, widthScale: 0.8)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        logoArea.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoArea.constrain(teamLogo, except: [.height, .width])
        teamLogo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        teamLogo.widthAnchor.constraint(equalToConstant: 25).isActive = true
        //teamLogo.backgroundColor = .cyan
    }
    
    private func setUpConstraints() {

        
        // We need constraints that define the height of the cell when closed and when open
        // to allow for animating between the two states.
        nameStack.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        
        closedConstraint =
            nameStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
            labelStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        openConstraint?.priority = .defaultLow
    }

    private func updateContent() {
        guard let teamInfo = teamInformation else { return }
        nameLabel.text = teamInfo.name
        foundedLabel.text = "Founded: \(teamInfo.founded ?? 0)"
        countryLabel.text = "Country: \(teamInfo.country ?? "")"
        codeLabel.text = "Code: \(teamInfo.code ?? "")"
        nationalLabel.text = "National: \(teamInfo.national)"
        
        loadImage(for: teamInfo)
    }
    
    /// Updates the views to reflect changes in selection
    private func updateAppearance() {

        
        UIView.animate(withDuration: 3) { // 0.3 seconds matches collection view animation
            // Set the rotation just under 180º so that it rotates back the same way
            self.closedConstraint?.isActive = !self.isSelected
            self.openConstraint?.isActive = self.isSelected
        }
    }
    
    private func loadImage(for team: TeamSearchData) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            self.teamLogo.image = image
            
            return
        }
        
        guard let url = URL(string: team.logo!) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.teamLogo.image = image
                    
                    Cached.data.save(image: image, uniqueName: imageName)
                }
            }
        }
    }
}
