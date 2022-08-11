//
//  MatchCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 
 
 */

class MatchCollectionCell: TeamDataStackCellModel {
    
    enum TeamType {
        case home, away
    }
    
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
    
    var dateStack = UIStackView(.horizontal)
    var homeTeamStack = UIStackView(.horizontal)
    var awayTeamStack = UIStackView(.horizontal)
    
    var homeImage = UIView()
    var awayImage = UIView()
    
    var homeImageView = UIImageView()
    var awayImageView = UIImageView()
    
    let greenLine = UIView()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
        setUpColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
        setUpColors()
    }
    
    // 1
    private func setUp() {
        
        //print("Set up for \(teamDataObject?.id)")
        
        contentStack.add(children: [(UIView(), 0.05), (dateStack, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (homeTeamStack, nil), (awayTeamStack, nil), (UIView(), 0.05),])
        
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
    }
    
    
    // 2
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        
        allLabels.forEach { $0.textColor = Colors.teamDataStackCellTextColor }
        greenLine.backgroundColor = Colors.teamDataStackCellTextColor
    }
    
    
    override func updateContent() {
        
        //print("Update Content for \(teamDataObject?.id)")
        
        
        
        Task.init {
            
            guard let teamDataObject = teamDataObject else { return }
            
            guard let match = await teamDataObject.match() else { print("Attempting to update content for match cell but matchInformation not found")
                return
            }
            guard let homeTeam = await Cached.data.teamDictionary(match.homeTeamId) else { print("Attempting to update content for match cell but home team with id \(match.homeTeamId) not found")
                return
            }
            guard let awayTeam = await match.awayTeam() else { print("Attempting to update content for match cell but away Team with id \(match.awayTeamId) not found")
                return
            }
            
            // Set data to UI elements
            homeTeamLabel.text = homeTeam.name
            awayTeamLabel.text = awayTeam.name
            dateLabel.text = match.timeStamp.formatted(date: .numeric, time: .omitted)
            homeTeamScore.text = String(match.homeTeamScore)
            awayTeamScore.text = String(match.awayTeamScore)
            
            await loadImage(for: homeTeam, teamType: .home)
            await loadImage(for: awayTeam, teamType: .away)
            
            self.alpha = 1
        }
    }
    
    private func loadImage(for team: TeamObject, teamType: TeamType) async {
        
        let imageName = "\(team.name) - \(team.id).png"
        

            if let image = await Cached.data.retrieveImage(from: imageName) {
                
                if teamType == .home {
                    self.homeImageView.image = image
                } else {
                    self.awayImageView.image = image
                }
                return
            }
        
        guard let logo = team.logo, let url = URL(string: logo)  else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    guard let image = UIImage(data: data) else { return }
                    if teamType == .home {
                        self.homeImageView.image = image
                    } else {
                        self.awayImageView.image = image
                    }
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        
        homeTeamLabel.text = "-"
        awayTeamLabel.text = "-"
        dateLabel.text = "-"
        homeTeamScore.text = "-"
        awayTeamScore.text = "-"
        
        self.homeImageView.image = nil
        self.awayImageView.image = nil
    }
}
