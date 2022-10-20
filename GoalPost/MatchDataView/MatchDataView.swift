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
    
    var teamMatchupArea = UIStackView(.horizontal)
    
    var homeTeamStack = UIStackView(.vertical)
    
    var homeTeamNameArea = UIView()
    var homeTeamLogoArea = UIView()
    var homeTeamScoreView = UIView()
    
    var centerStack = UIStackView(.vertical)
    
    var vsStack = UIStackView(.vertical)
    var statusView = UIView()
    

    var awayTeamStack = UIStackView(.vertical)

    var awayTeamNameArea = UIView()
    var awayTeamLogoArea = UIView()
    var awayTeamScoreView = UIView()
    
    // Events Area
    
    var eventsArea = UIScrollView()
    var eventsStack = UIStackView(.vertical)
    
    var homeTeamEventsStack = UIStackView(.horizontal)
    var centerEventsStack = UIStackView(.horizontal)
    var awayTeamEventsStack = UIStackView(.horizontal)
    
    
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
    
    var greenHorizontalLine: ((CGFloat) -> UIStackView) = {
        var stackView = UIStackView(.vertical)
        let greenLine = UIView()
        greenLine.backgroundColor = Colors.cellTextGreen
        greenLine.heightAnchor.constraint(equalToConstant: $0).isActive = true
        
        stackView.add(children: [(UIView(), 0.4), (greenLine, nil), (UIView(), nil)])
        
        return stackView
    }
    
    var greenVerticalLine: ((CGFloat) -> UIStackView) = {
        var stackView = UIStackView(.horizontal)
        let greenLine = UIView()
        greenLine.backgroundColor = Colors.cellTextGreen
        greenLine.widthAnchor.constraint(equalToConstant: $0).isActive = true
        
        stackView.add(children: [(UIView(), 0.4), (greenLine, nil), (UIView(), nil)])
        
        return stackView
    }
    
    var spacer: ((CGFloat?) -> (UIView, CGFloat?)) = {
        return (UIView(), $0)
    }
    
    // MARK: Data
    var match: MatchObject? { didSet { updateContent() } }
    
    var viewController: MatchDataViewController!
    
    // For Checking Membership
    var allEvents = Set<EventObject>()
    
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
        
        mainStack.add(children: [(dateStack, 0.15), (teamMatchupArea, 0.4), spacer(nil), (eventsArea, 0.4)])
        
        dateStack.add(children: [spacer(0.05), (dateArea, nil), (timeArea, nil), spacer(0.05), (greenHorizontalLine(2), nil)])
        
        dateArea.constrain(dateLabel)
        timeArea.constrain(timeLabel)
        
        teamMatchupArea.add(children: [spacer(0.05), (homeTeamStack, 0.3), spacer(0.05), (centerStack, nil), spacer(0.05), (awayTeamStack, 0.3), spacer(0.05)])
        
        let topSacer = 0.05
        let midSpacer = 0.1
        let nameArea = 0.35
        let logoArea = 0.25
        let scoreAndStatusView = 0.25
        
        homeTeamStack.add(children: [spacer(topSacer), (homeTeamNameArea, nameArea), (homeTeamLogoArea, logoArea), spacer(midSpacer), (homeTeamScoreView, scoreAndStatusView), spacer(nil)])
        awayTeamStack.add(children: [spacer(topSacer), (awayTeamNameArea, nameArea), (awayTeamLogoArea, logoArea), spacer(midSpacer), (awayTeamScoreView, scoreAndStatusView), spacer(nil)])
        centerStack.add(children: [spacer(topSacer), (greenVerticalLine(2), 0.25), (vsStack, 0.15), (greenVerticalLine(2), 0.2), spacer(midSpacer + 0.05), (statusView, scoreAndStatusView - 0.05), spacer(nil)])
        
        
        homeTeamNameArea.constrain(homeTeamLabel)
        awayTeamNameArea.constrain(awayTeamLabel)
        
        homeTeamLogoArea.constrain(homeTeamLogo, using: .scale, except: [.height])
        awayTeamLogoArea.constrain(awayTeamLogo, using: .scale, except: [.height])
        
        homeTeamLogo.heightAnchor.constraint(equalTo: awayTeamLogo.widthAnchor).isActive = true
        awayTeamLogo.heightAnchor.constraint(equalTo: awayTeamLogo.widthAnchor).isActive = true
        
        vsStack.add([vsLabel])
        
        homeTeamScoreView.constrain(homeTeamScoreLabel)
        awayTeamScoreView.constrain(awayTeamScoreLabel)
        statusView.constrain(statusLabel)


        eventsArea.constrain(eventsStack, using: .edges)
        eventsStack.widthAnchor.constraint(greaterThanOrEqualTo: eventsArea.widthAnchor).isActive = true
        eventsStack.heightAnchor.constraint(equalTo: eventsArea.heightAnchor).isActive = true
        
        eventsStack.add(children: [(homeTeamEventsStack, 0.4), spacer(0.02), (centerEventsStack, nil), spacer(0.02), (awayTeamEventsStack, 0.4)])
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
        
        homeTeamLabel.numberOfLines = -1
        awayTeamLabel.numberOfLines = -1
        
        homeTeamScoreLabel.font = UIFont.systemFont(ofSize: 20)
        awayTeamScoreLabel.font = UIFont.systemFont(ofSize: 20)
        
        vsLabel.font = UIFont.systemFont(ofSize: 36)
        vsLabel.textAlignment = .left
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
        
        Task.init {
            try await DataFetcher.helper.getEvents(for: match.id, completion: { self.add(events: $0) })
        }
    }
    
    func add(events: [EventObject]) {
        guard let match = self.match, let homeTeam = match.homeTeam, let awayTeam = match.awayTeam else { return }
        
        for event in events {
            
            guard !self.allEvents.contains(event) else {
                return
            }
            
            self.allEvents.insert(event)

            DispatchQueue.main.async {
                
                let width: CGFloat = 125
                let logoWidth: CGFloat = 40
                
                let view = EventView(event, width: width, logoWidth: logoWidth)
                let secondView = EventView(nil, width: width, logoWidth: logoWidth)
                
                let timeView = UIView()
                let timeLabel = UILabel()
                timeView.constrain(timeLabel)
                timeView.widthAnchor.constraint(equalToConstant: logoWidth).isActive = true
                timeLabel.text = "\(event.timeElapsed)'\(event.extraTimeElapsed != nil ? " +\(event.extraTimeElapsed!)" : "")"
                timeLabel.textAlignment = .center
                
                let centerSegment = UIStackView(.horizontal)
                centerSegment.widthAnchor.constraint(equalToConstant: width).isActive = true
                centerSegment.add([self.greenHorizontalLine(2), timeLabel, self.greenHorizontalLine(2)])
                centerSegment.distribution = .fillEqually
                
                if event.teamId == homeTeam.id {
                    self.homeTeamEventsStack.addArrangedSubview(view)
                    self.centerEventsStack.addArrangedSubview(centerSegment)
                    self.awayTeamEventsStack.addArrangedSubview(secondView)
                } else {
                    self.awayTeamEventsStack.addArrangedSubview(view)
                    self.centerEventsStack.addArrangedSubview(centerSegment)
                    self.homeTeamEventsStack.addArrangedSubview(secondView)
                }
            }
        }
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
