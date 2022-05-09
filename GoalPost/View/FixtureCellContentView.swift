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
    var startTimeLabel = UILabel()
    var timeElapsedLabel = UILabel()
    
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
    var timeStack = UIStackView(.vertical)

    
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
        
        
        // MARK: Set up stacks
        /*
        mainStack.add(children: [(homeImage, nil), (vsLabel, nil), (awayImage, nil), (labelStack, 0.7), (timeStack, nil)])
        mainStack.setCustomSpacing(4, after: homeImage)
        mainStack.setCustomSpacing(4, after: vsLabel)
        mainStack.setCustomSpacing(7, after: awayImage)
        
        labelStack.add([homeTeamStack, awayTeamStack])
        
        homeTeamStack.add(children: [(homeTeamLabel, 0.9), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayTeamLabel, 0.9), (awayTeamScore, nil)])
        timeStack.addArrangedSubview(timeLabel)
        
        // MARK: Format labels
        allLabels.forEach { $0.textColor = Colors.darkColor }
        
        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 0, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        
        
        awayImage.constrain(awayImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 0, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        homeImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        homeImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        awayImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        awayImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        imageStack.alignment = .center
         */
        mainStack.add([topStack, bottomStack])

        mainStack.setCustomSpacing(10, after: topStack)
        
        topStack.add(children: [(homeTeamStack, 0.75), (startTimeLabel, nil)])
        bottomStack.add(children: [(awayTeamStack, 0.75), (timeElapsedLabel, nil)])
        
        homeTeamStack.add(children: [(homeImage, nil), (homeTeamLabel, 0.8), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayImage, nil), (awayTeamLabel, 0.8), (awayTeamScore, nil)])
        //timeStack.addArrangedSubview(startTimeLabel)
        
        homeTeamStack.setCustomSpacing(5, after: homeImage)
        awayTeamStack.setCustomSpacing(5, after: awayImage)
        
        // MARK: Format labels
        allLabels.forEach { $0.textColor = Colors.darkColor }
        
        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        
        
        awayImage.constrain(awayImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        homeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        homeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
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
        awayTeamLabel.text = fixture.awayTeam.name
        startTimeLabel.text = fixture.timeStamp.formatted(date: .omitted, time: .shortened)
        homeTeamScore.text = String(fixture.homeTeam.score)
        awayTeamScore.text = String(fixture.awayTeam.score)
        timeElapsedLabel.text = String(fixture.timeElapsed)
        
        vsLabel.text = "-"
        vsLabel.sizeToFit()
        imageStack.layoutSubviews()
        
        /*TEST DATA*/
        
        //loadImage(for: fixture.homeTeam, teamType: .home)
        //loadImage(for: fixture.awayTeam, teamType: .away)
        
        //homeImageView.image = UIImage(named: "Default Home Icon")
        //awayImageView.image = UIImage(named: "Default Away Icon")
    }
    
    enum TeamType {
        case home, away
    }
    
    private func loadImage(for team: FixtureTeamData, teamType: TeamType) {

        // Create URL
        let url = URL(string: team.logoURL)!

        DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    if teamType == .home {
                        self.homeImageView.image = UIImage(data: data)
                    } else {
                        self.awayImageView.image = UIImage(data: data)
                    }
                    
                }
            }
        }
        
        return
        
        // Load Image
        let image = UIImage(named: "landscape")

        // Convert to Data
        if let data = image?.pngData() {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent("landscape.png")

            do {
                // Write to Disk
                try data.write(to: url)

                // Store URL in User Defaults
                UserDefaults.standard.set(url, forKey: "background")

            } catch {
                print("Unable to Write Data to Disk (\(error))")
            }
        }
    }
}
