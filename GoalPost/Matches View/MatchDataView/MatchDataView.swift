//
//  MatchDataView.swift
//  GoalPost
//
//  Created by Moses Harding on 10/11/22.
//

import Foundation
import UIKit

class MatchDataView: UIView {
    let mainStack = UIStackView(.vertical)
    
    let nameArea = UIView()
    let detailsStack = UIStackView(.vertical)

    // Labels
    var nameLabel = UILabel()
    var timestampLabel = UILabel()
    var timezoneLabel = UILabel()
    var timeElapsedLabel = UILabel()
    
    var homeTeamLabel = UILabel()
    var homeTeamScoreLabel = UILabel()
    var awayTeamLabel = UILabel()
    var awayTeamScoreLabel = UILabel()
    
    var statusLabel = UILabel()
    
    var favoriteTeamLabel = UILabel()
    
    var leagueLabel = UILabel()
    
    // Data
    var match: MatchObject? { didSet { updateContent() } }
    
    var viewController: MatchDataViewController!
    
    init() {
        super.init(frame: .zero)

        setUpMainStack()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        // Set Up Structure

        self.constrain(mainStack)
        
        mainStack.add(children: [(UIView(), 0.05), (nameArea, 0.05), (UIView(), 0.05), (detailsStack, nil), (UIView(), 0.05)])
        
        nameArea.constrain(nameLabel, using: .scale, widthScale: 0.8, debugName: "Name label to name area - MatchDataView")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textAlignment = .center
        
        detailsStack.add([nameLabel, timestampLabel, timezoneLabel, timeElapsedLabel, homeTeamLabel, homeTeamScoreLabel, awayTeamLabel, awayTeamScoreLabel, statusLabel, favoriteTeamLabel, leagueLabel])
    }
    
    
    // 3
    func setUpColors() {
        self.backgroundColor = Colors.cellBackgroundGray
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MatchDataView {
    
    func updateContent() {
            guard let match = self.match else { return }
            self.nameLabel.text = match.uniqueID
            
        
        timestampLabel.text = "timestamp: \(match.timeStamp)"
        timezoneLabel.text = "timezone: \(match.timezone)"
        timeElapsedLabel.text = "timeElapsed: \(match.timeElapsed)"
        
        homeTeamLabel.text = "homeTeam: \(match.homeTeam)"
        homeTeamScoreLabel.text = "homeTeamScore: \(match.homeTeamScore)"
        awayTeamLabel.text = "awayTeam: \(match.awayTeam)"
        awayTeamScoreLabel.text = "awayTeamScore: \(match.awayTeamScore)"
        
        statusLabel.text = "status: \(match.status)"
        
        favoriteTeamLabel.text = "favoriteTeam: \(match.favoriteTeam)"
        
        leagueLabel.text = "league: \(match.league)"
    }
    
}
