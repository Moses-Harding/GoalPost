//
//  MatchDataView.swift
//  GoalPost
//
//  Created by Moses Harding on 10/11/22.
//

import Foundation
import UIKit

class MatchDataView: UIView {
    
    // MARK: Views
    
    let mainStack = UIStackView(.vertical)
    
    // Date Area
    
    var dateStack = UIStackView(.vertical)
    var dateArea = UIView()
    var timeArea = UIView()
    
    // Name + Logo Area
    var namesAndLogoStack = UIStackView(.vertical)

    // - Name Stack
    var nameStack = UIStackView(.horizontal)
    var homeTeamNameArea = UIView()
    var awayTeamNameArea = UIView()
    
    // - Logo Stack
    var logoStack = UIStackView(.horizontal)
    var homeTeamLogoArea = UIView()
    var awayTeamLogoArea = UIView()
    var vsStack = UIStackView(.vertical)
    
    // Score Area
    
    var scoreStack = UIStackView(.horizontal)
    var homeTeamScoreView = UIView()
    var awayTeamScoreView = UIView()
    var statusView = UIView()
    
    
    // MARK: Labels
    
    // Date Area
    var dateLabel = UILabel()
    var timeLabel = UILabel()
    
    // Name + Logo Area
    var homeTeamLabel = UILabel()
    var awayTeamLabel = UILabel()
    var vsLabel = UILabel()
    
    // Score Area
    var homeTeamScoreLabel = UILabel()
    var awayTeamScoreLabel = UILabel()
    var statusLabel = UILabel()
    
    var allLabels: [UILabel] { [dateLabel, timeLabel, homeTeamLabel, awayTeamLabel, vsLabel, homeTeamScoreLabel, awayTeamScoreLabel, statusLabel] }
    
    // MARK: Images
    
    var homeTeamLogo = UIImageView()
    var awayTeamLogo = UIImageView()
    
    // MARK: Closures
    
    let greenHorizontalLine: (() -> UIView) = {
        let view = UIView()
        view.backgroundColor = Colors.cellTextGreen
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        return view
    }
    
    var greenVerticalLine: (() -> UIView) = {
        let view = UIView()
        view.backgroundColor = Colors.cellTextGreen
        view.widthAnchor.constraint(equalToConstant: 2).isActive = true
        return view
    }
    
    var spacer: ((CGFloat?) -> (UIView, CGFloat?)) = {
        return (UIView(), $0)
    }
    
    // Data
    var match: MatchObject? { didSet { updateContent() } }
    
    var viewController: MatchDataViewController!
    
    init() {
        super.init(frame: .zero)

        setUpMainStack()
        setUpColors()
        formatLabels()
    }
    
    // 1
    func setUpMainStack() {
        // Set Up Structure

        self.constrain(mainStack)
        
        mainStack.add(children: [(dateStack, 0.15), (namesAndLogoStack, 0.3), (scoreStack, 0.1), spacer(nil)])
        
        dateStack.add([UIView(), dateArea, timeArea, UIView(), greenHorizontalLine()])
        
        dateArea.constrain(dateLabel)
        timeArea.constrain(timeLabel)
        
        namesAndLogoStack.add(children: [(nameStack, 0.3), (logoStack, 0.5), spacer(nil)])
        nameStack.add(children: [spacer(0.1), (homeTeamNameArea, 0.3), spacer(0.09), (greenVerticalLine(), 0.02), spacer(0.1), (awayTeamNameArea, 0.3), spacer(nil)])
        logoStack.add(children: [spacer(0.1), (homeTeamLogoArea, 0.2), spacer(0.1), (vsStack, nil), spacer(0.1), (awayTeamLogoArea, 0.2), spacer(0.1)])
        
        homeTeamNameArea.constrain(homeTeamLabel)
        awayTeamNameArea.constrain(awayTeamLabel)
        
        homeTeamLogoArea.constrain(homeTeamLogo, using: .scale, except: [.height])
        awayTeamLogoArea.constrain(awayTeamLogo, using: .scale, except: [.height])
        
        homeTeamLogo.heightAnchor.constraint(equalTo: awayTeamLogo.widthAnchor).isActive = true
        awayTeamLogo.heightAnchor.constraint(equalTo: awayTeamLogo.widthAnchor).isActive = true
        
        let lineStack = UIStackView(.horizontal)
        lineStack.add(children: [spacer(0.4), (greenVerticalLine(), nil), spacer(nil)])
        vsStack.add(children: [(vsLabel, 0.6), spacer(0.01), (lineStack, nil)])
        
        scoreStack.add(children: [spacer(0.05), (homeTeamScoreView, 0.3), spacer(0.1), (statusView, nil), spacer(0.1), (awayTeamScoreView, 0.3), spacer(0.05)])
        homeTeamScoreView.constrain(homeTeamScoreLabel)
        awayTeamScoreView.constrain(awayTeamScoreLabel)
        statusView.constrain(statusLabel)
    }
    
    
    // 3
    func setUpColors() {
        self.backgroundColor = Colors.backgroundColor
        
        homeTeamScoreView.layer.borderColor = Colors.cellBorderGreen.cgColor
        homeTeamScoreView.layer.borderWidth = 1
        homeTeamScoreView.layer.cornerRadius = 15
        
        awayTeamScoreView.layer.borderColor = Colors.cellBorderGreen.cgColor
        awayTeamScoreView.layer.borderWidth = 1
        awayTeamScoreView.layer.cornerRadius = 15
        
        statusView.backgroundColor = Colors.cellBackgroundGray
        statusView.layer.cornerRadius = 15
    }
    
    // 4
    
    func formatLabels() {
        
        allLabels.forEach { $0.textAlignment = .center }
        
        dateLabel.font = UIFont.systemFont(ofSize: 36)
        timeLabel.font = UIFont.systemFont(ofSize: 36)
        
        homeTeamLabel.font = UIFont.systemFont(ofSize: 24)
        awayTeamLabel.font = UIFont.systemFont(ofSize: 24)
        
        homeTeamScoreLabel.font = UIFont.systemFont(ofSize: 20)
        awayTeamScoreLabel.font = UIFont.systemFont(ofSize: 20)
        
        vsLabel.font = UIFont.systemFont(ofSize: 36)
        vsLabel.textAlignment = .left
        
        
        /*
        homeTeamNameArea.backgroundColor = .blue
        awayTeamNameArea.backgroundColor = .blue
        vsLabel.backgroundColor = .blue
         */
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MatchDataView {
    
    func updateContent() {
        guard let match = self.match, let homeTeam = match.homeTeam, let awayTeam = match.awayTeam else { return }
        
        dateLabel.text = "\(match.timeStamp.formatted(date: .abbreviated, time: .omitted))"
        timeLabel.text = "\(match.timeStamp.formatted(date: .omitted, time: .shortened))"

        
        vsLabel.text = "  VS"
        
        homeTeamLabel.text = "\(match.homeTeam?.name ?? "")"
        homeTeamScoreLabel.text = "\(String(match.homeTeamScore)) "
        
        awayTeamLabel.text = "\(match.awayTeam?.name ?? "")"
        awayTeamScoreLabel.text = "\(String(match.awayTeamScore)) "
        
        statusLabel.text = "\(match.timeElapsed ?? 0)'"
        
        loadImage(for: homeTeam, teamType: .home)
        loadImage(for: awayTeam, teamType: .away)
    }
    
    enum TeamType {
        case home, away
    }
    
    private func loadImage(for team: TeamObject, teamType: TeamType) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        Task.init {
            if let image = QuickCache.helper.retrieveImage(from: imageName) {
                
                if teamType == .home {
                    self.homeTeamLogo.image = image
                } else {
                    self.awayTeamLogo.image = image
                }
                
                return
            }
        }
        
        guard let logo = team.logo, let url = URL(string: logo)  else { return }
        

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    if teamType == .home {
                        self.homeTeamLogo.image = image
                    } else {
                        self.awayTeamLogo.image = image
                    }
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
}
