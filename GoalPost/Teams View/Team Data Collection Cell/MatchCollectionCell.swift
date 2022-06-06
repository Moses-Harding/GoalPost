//
//  MatchCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class MatchCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamDataObject: TeamDataObject? { didSet { updateContent() } }
    
    // MARK: - Private Properties
    
    //MARK: Labels
    
    var homeTeamLabel = UILabel()
    var awayTeamLabel = UILabel()
    var homeTeamScore = UILabel()
    var awayTeamScore = UILabel()

    var dateLabel = UILabel()
    
    var allLabels: [UILabel] {
        return [homeTeamLabel, awayTeamLabel, homeTeamScore, awayTeamScore, dateLabel]
    }
    
    //MARK: Views
    
    var verticalStack = UIStackView(.vertical)
    var mainStack = UIStackView(.vertical)
    var topStack = UIStackView(.horizontal)
    var bottomStack = UIStackView(.horizontal)
    
    var dateStack = UIStackView(.horizontal)
    var homeTeamStack = UIStackView(.horizontal)
    var awayTeamStack = UIStackView(.horizontal)
    
    var imageStack = UIStackView(.horizontal)
    var labelStack = UIStackView(.vertical)

    var homeImage = UIView()
    var awayImage = UIView()
    
    var homeImageView = UIImageView()
    var awayImageView = UIImageView()
    
    
    //MARK: Lines
    
    var line = UIView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
        setUpColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    private func setUp() {

        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
        
        mainStack.add([UIView(), dateStack, homeTeamStack, awayTeamStack, UIView()])

        mainStack.setCustomSpacing(10, after: dateStack)
        
        dateStack.add([dateLabel])
        homeTeamStack.add(children: [(homeImage, nil), (homeTeamLabel, 0.8), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayImage, nil), (awayTeamLabel, 0.8), (awayTeamScore, nil)])
        
        homeTeamStack.setCustomSpacing(10, after: homeImage)
        awayTeamStack.setCustomSpacing(10, after: awayImage)
        
        // MARK: Format labels
        allLabels.forEach { $0.textColor = Colors.cellBodyTextColor }
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        
        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        
        
        awayImage.constrain(awayImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        homeImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        homeImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        awayImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        imageStack.alignment = .center
    }

    func updateContent() {
        guard let match = teamDataObject?.match, let homeTeam = match.homeTeam, let awayTeam = match.awayTeam else { return }
        
        // Set data to UI elements
        homeTeamLabel.text = homeTeam.name
        awayTeamLabel.text = awayTeam.name
        dateLabel.text = match.timeStamp.formatted(date: .numeric, time: .omitted)
        homeTeamScore.text = String(match.homeTeamScore)
        awayTeamScore.text = String(match.awayTeamScore)

        loadImage(for: homeTeam, teamType: .home)
        loadImage(for: awayTeam, teamType: .away)
    }
    
    enum TeamType {
        case home, away
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        self.layer.cornerRadius = 10
        //self.layer.shadowColor = UIColor.black.cgColor
        //self.layer.shadowOpacity = 1
        //self.layer.shadowOffset = .zero
        //self.layer.shadowRadius = 5
        //self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        //self.layer.borderColor = Colors.logoTheme.cgColor
        //self.layer.borderWidth = 1
    }
    
    private func loadImage(for team: TeamObject, teamType: TeamType) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            if teamType == .home {
                self.homeImageView.image = image
            } else {
                self.awayImageView.image = image
            }
            
            return
        }
        
        guard let logo = team.logo, let url = URL(string: logo)  else { return }

        //let url = URL(string: team.logo)!

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
