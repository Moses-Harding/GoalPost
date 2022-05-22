//
//  FixtureCell.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class FixtureCell: UICollectionViewListCell {
    
    var fixture: MatchData?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Remove gray background when selected:
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = Colors.cellBodyColor
        self.backgroundConfiguration = backgroundConfiguration
            
        // Create new configuration object and update it base on state
        var newConfiguration = FixtureCellContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        newConfiguration.fixture = fixture

        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
    }
}

struct FixtureCellContentConfiguration: UIContentConfiguration, Hashable {
    
    var fixture: MatchData?
    
    func makeContentView() -> UIView & UIContentView {
        return FixtureCellContentView(configuration: self)
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

class FixtureCellContentView: UIView, UIContentView {
    
    //MARK: Labels
    
    var homeTeamLabel = UILabel()
    var awayTeamLabel = UILabel()
    var homeTeamScore = UILabel()
    var awayTeamScore = UILabel()
    var vsLabel = UILabel()
    var startTimeLabel = UILabel()
    var timeElapsedLabel = UILabel() {
        willSet {
            if newValue.text == "" || newValue.text == nil{
                statusOutline.isHidden = true
            } else {
                statusOutline.isHidden = false
            }
        }
    }
    
    var allLabels: [UILabel] {
        return [homeTeamLabel, awayTeamLabel, homeTeamScore, awayTeamScore, vsLabel, startTimeLabel, timeElapsedLabel]
    }
    
    //MARK: Views
    
    var verticalStack = UIStackView(.vertical)
    var mainStack = UIStackView(.vertical)
    var topStack = UIStackView(.horizontal)
    var bottomStack = UIStackView(.horizontal)
    
    var homeTeamStack = UIStackView(.horizontal)
    var awayTeamStack = UIStackView(.horizontal)
    
    var imageStack = UIStackView(.horizontal)
    var labelStack = UIStackView(.vertical)
    var statusStack = UIStackView(.horizontal)
    var statusOutline = UIView()

    
    var homeImage = UIView()
    var awayImage = UIView()
    
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
            guard let newConfiguration = newValue as? FixtureCellContentConfiguration else {
                return
            }
            
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
        
        mainStack.add([topStack, bottomStack])

        mainStack.setCustomSpacing(10, after: topStack)
        
        topStack.add(children: [(homeTeamStack, 0.75), (startTimeLabel, nil)])
        bottomStack.add(children: [(awayTeamStack, 0.75), (statusStack, nil)])
        
        homeTeamStack.add(children: [(homeImage, nil), (homeTeamLabel, 0.8), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayImage, nil), (awayTeamLabel, 0.8), (awayTeamScore, nil)])
        
        homeTeamStack.setCustomSpacing(10, after: homeImage)
        awayTeamStack.setCustomSpacing(10, after: awayImage)
        
        // MARK: Format labels
        allLabels.forEach { $0.textColor = Colors.cellBodyTextColor }
        timeElapsedLabel.font = UIFont.systemFont(ofSize: 12)
        startTimeLabel.textAlignment = .center
        
        // MARK: Format Individual Views
        
        statusStack.add(children: [(UIView(), nil), (statusOutline, nil), (UIView(), nil)])
        statusStack.distribution = .equalCentering
        statusOutline.constrain(timeElapsedLabel, using: .scale, heightScale: 1.0, padding: 0, except: [.width], safeAreaLayout: false, debugName: "Time Elapsed Outline Constraining TIme Elapsed Label")
        statusOutline.layer.borderColor = Colors.titleAreaTextColor.cgColor
        statusOutline.layer.borderWidth = 1
        statusOutline.layer.cornerRadius = 10
        statusOutline.widthAnchor.constraint(equalTo: timeElapsedLabel.widthAnchor, multiplier: 2).isActive = true
        
        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        
        
        awayImage.constrain(awayImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        homeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        homeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        imageStack.alignment = .center
    }
    
    private func setStatus(from status: FixtureStatusCode, time: Int?) {
        
        if status == .notStarted {
            statusOutline.isHidden = true
            return
        } else {
            statusOutline.isHidden = false
        }
        
        let matchInterruption = { [self] in
            statusOutline.layer.borderWidth = 0
            statusOutline.backgroundColor = Colors.statusRed
            timeElapsedLabel.text = status.rawValue
        }
        
        let finished = { [self] in
            statusOutline.layer.borderWidth = 0
            statusOutline.backgroundColor = Colors.titleAreaColor
                //timeElapsedLabel.backgroundColor = Colors.statusRed
            timeElapsedLabel.text = "FT"
        }
        
        switch status {
        case .suspended:
            matchInterruption()
        case .interrupted:
            matchInterruption()
        case .postponed:
            matchInterruption()
        case .cancelled:
            matchInterruption()
        case .abandoned:
            matchInterruption()
        case .technicalLoss:
            matchInterruption()
        case .finished:
            finished()
        case .finishedAfterPenalties:
            finished()
        case .finishedAfterExtraTime:
            finished()
        default:
            timeElapsedLabel.text = " " + String(time) + " "
        }
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
        awayTeamLabel.text = fixture.awayTeam.name
        startTimeLabel.text = fixture.timeStamp.formatted(date: .omitted, time: .shortened)
        homeTeamScore.text = String(fixture.homeTeam.score)
        awayTeamScore.text = String(fixture.awayTeam.score)
        setStatus(from: fixture.status, time: fixture.timeElapsed)
        
        vsLabel.text = "-"
        vsLabel.sizeToFit()
        //imageStack.layoutSubviews()
        
        loadImage(for: fixture.homeTeam, teamType: .home)
        loadImage(for: fixture.awayTeam, teamType: .away)
    }
    
    enum TeamType {
        case home, away
    }
    
    private func loadImage(for team: MatchTeamData, teamType: TeamType) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            if teamType == .home {
                self.homeImageView.image = image
            } else {
                self.awayImageView.image = image
            }
            
            return
        }

        let url = URL(string: team.logoURL)!

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    if teamType == .home {
                        self.homeImageView.image = image
                    } else {
                        self.awayImageView.image = image
                    }
                    
                    Cached.data.save(image: image, uniqueName: imageName)
                }
            }
        }
    }
}
