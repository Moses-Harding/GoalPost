//
//  MatchesViewListCell.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit

class MatchCell: UICollectionViewCell {
    
    var oldObjectContainer: ObjectContainer?
    var objectContainer: ObjectContainer? { didSet { updateData() } }
    
    var homeTeamLabel = UILabel()
    var awayTeamLabel = UILabel()
    var homeTeamScore = UILabel()
    var awayTeamScore = UILabel()
    var vsLabel = UILabel()
    var startTimeLabel = UILabel()
    var timeElapsedLabel = UILabel() {
        willSet {
            if newValue.text == "" || newValue.text == nil{
                statusArea.isHidden = true
            } else {
                statusArea.isHidden = false
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
    //var statusStack = UIStackView(.vertical)
    var statusArea = UIView()
    var statusBackgroundStack = UIStackView(.horizontal)
    var separator = UIView()
    
    var homeImage = UIView()
    var awayImage = UIView()
    
    var homeImageView = UIImageView()
    var awayImageView = UIImageView()
    
    var homeImageWidthConstraint: NSLayoutConstraint?
    var homeImageHeightConstraint: NSLayoutConstraint?
    var awayImageWidthConstraint: NSLayoutConstraint?
    var awayImageHeightConstraint: NSLayoutConstraint?
    
    var allFixedConstraints: [NSLayoutConstraint?] {
        return  [homeImageWidthConstraint, homeImageHeightConstraint, awayImageWidthConstraint, awayImageHeightConstraint]
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupAllViews()
        setColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAllViews()
        setColors()
    }
    
    private func setupAllViews() {
        
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutMarginsGuide = layoutMarginsGuide
        
        let leadingMain = mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        let trailingMain = mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        let topMain = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor)
        let bottomMain = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        NSLayoutConstraint.activate([ leadingMain, trailingMain, topMain, bottomMain ])
        
        leadingMain.identifier = "MatchCell - MainStack To ContentView - Leading"
        trailingMain.identifier = "MatchCell - MainStack To ContentView - Trailing"
        topMain.identifier = "MatchCell - MainStack To ContentView - Top"
        bottomMain.identifier = "MatchCell - MainStack To ContentView - Bottom"
        
        layoutMarginsGuide.identifier = "MatchCell - LayoutMarginsGuide"
        
        mainStack.accessibilityIdentifier = "MainStack"
        topStack.accessibilityIdentifier = "TopStack"
        bottomStack.accessibilityIdentifier = "BottomStack"
        contentView.accessibilityIdentifier = "ContentView"
        homeTeamStack.accessibilityIdentifier = "HomeTeamStack"
        awayTeamStack.accessibilityIdentifier = "AwayTemStack"
        statusBackgroundStack.accessibilityIdentifier = "StatusBackgroundArea"
        statusArea.accessibilityIdentifier = "StatusArea"
        imageStack.accessibilityIdentifier = "ImageStack"
        startTimeLabel.accessibilityIdentifier = "StartTimeLabel"
        homeImage.accessibilityIdentifier = "HomeImage"
        awayImage.accessibilityIdentifier = "AwayImage"
        timeElapsedLabel.accessibilityIdentifier = "TimeElapsedLabel"

        mainStack.add([separator, topStack, bottomStack])
        
        topStack.heightAnchor.constraint(equalTo: bottomStack.heightAnchor).isActive = true
        topStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        topStack.add(children: [(homeTeamStack, 0.75), (startTimeLabel, nil)])
        bottomStack.add(children: [(awayTeamStack, 0.75), (statusArea, nil)])
        
        homeTeamStack.add(children: [(homeImage, nil), (homeTeamLabel, 0.8), (homeTeamScore, nil)])
        awayTeamStack.add(children: [(awayImage, nil), (awayTeamLabel, 0.8), (awayTeamScore, nil)])
        
        homeTeamStack.setCustomSpacing(10, after: homeImage)
        awayTeamStack.setCustomSpacing(10, after: awayImage)
        
        // MARK: Format labels
        
        allLabels.forEach { $0.textColor = Colors.cellBodyTextColor }
        
        startTimeLabel.textAlignment = .center
        
        // MARK: Format Individual Views

        statusArea.constrain(statusBackgroundStack, using: .scale, widthScale: 0.5, heightScale: 0.8, debugName: "StatusBackgroundArea -> StatusArea")
        statusBackgroundStack.constrain(timeElapsedLabel, using: .scale, debugName: "TimeElapsedLabel -> StatusArea")
        statusBackgroundStack.layer.borderColor = Colors.titleAreaTextColor.cgColor
        statusBackgroundStack.layer.borderWidth = 1
        statusBackgroundStack.layer.cornerRadius = 10

        timeElapsedLabel.font = UIFont.systemFont(ofSize: 12)
        timeElapsedLabel.textAlignment = .center
        timeElapsedLabel.adjustsFontSizeToFitWidth = true
        timeElapsedLabel.minimumScaleFactor = 0.2
        

        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        awayImage.constrain(awayImageView, using: .scale, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        imageStack.alignment = .center
        
        refreshCellConstraints()
    }
    
    func setColors() {
        // self.contentView.backgroundColor = .black
    }
    
    func refreshCellConstraints() {
        
        if let container = objectContainer {
            separator.backgroundColor = container.showSeperator ? Colors.gray.hex282B28 : .clear
        }
        
        allFixedConstraints.forEach { $0?.isActive = false }

        homeImageHeightConstraint = homeImageView.heightAnchor.constraint(equalToConstant: 20)
        homeImageWidthConstraint = homeImageView.widthAnchor.constraint(equalToConstant: 20)
        awayImageHeightConstraint = awayImageView.heightAnchor.constraint(equalToConstant: 20)
        awayImageWidthConstraint = awayImageView.widthAnchor.constraint(equalToConstant: 20)
        
        allFixedConstraints.forEach { $0?.isActive = true }
    }
    
    private func setStatus() {
        
        guard let match = objectContainer?.match else {
            fatalError("No match found")
        }
        
        let status = match.status
        let time = match.timeElapsed

        var cellBackgroundColor = UIColor.clear
        var statusBackgroundColor = UIColor.clear
        var borderColor = UIColor.clear
        var borderWidth: CGFloat = 0
        var timeElapsed = ""
        
        switch status {
        case .notStarted:
            timeElapsed = ""
        case .suspended:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .interrupted:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .postponed:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .cancelled:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .abandoned:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .technicalLoss:
            timeElapsed = status.rawValue
            borderWidth = 1
            borderColor = Colors.statusRed
        case .tbd:
            statusBackgroundColor = Colors.titleAreaColor
            timeElapsed = "TBD"
        case .finished:
            statusBackgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        case .finishedAfterPenalties:
            statusBackgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        case .finishedAfterExtraTime:
            statusBackgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        default:
            timeElapsed = String(time) + "'"
            borderWidth = 1
            borderColor = Colors.cellSecondaryTextColor
            cellBackgroundColor = Colors.cellHighlightedBackgroundColor
        }

        statusBackgroundStack.backgroundColor = statusBackgroundColor
        statusBackgroundStack.layer.borderWidth = borderWidth
        statusBackgroundStack.layer.borderColor = borderColor.cgColor
        timeElapsedLabel.text = timeElapsed
        backgroundColor = cellBackgroundColor
    }
    
    func updateData() {
        
        guard let match = objectContainer?.match, let homeTeam = match.homeTeam, let awayTeam = match.awayTeam else { return }
        
        var newMatch: Bool = false
        
        
        if let oldObjectContainer = oldObjectContainer, let newObjectContainer = objectContainer, oldObjectContainer == newObjectContainer {
            newMatch = false
        } else {
            newMatch = true
        }
        
        oldObjectContainer = objectContainer
        
        refreshCellConstraints()
        
        homeTeamScore.text = String(match.homeTeamScore)
        awayTeamScore.text = String(match.awayTeamScore)
        startTimeLabel.text = match.timeStamp.formatted(date: .omitted, time: .shortened)
        setStatus()
        
        if newMatch {
            
            Task.init {
            homeTeamLabel.text = homeTeam.name
            awayTeamLabel.text = awayTeam.name

            vsLabel.text = "-"
            vsLabel.sizeToFit()
            
                loadImage(for: homeTeam, teamType: .home)
                loadImage(for: awayTeam, teamType: .away)
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
                    self.homeImageView.image = image
                } else {
                    self.awayImageView.image = image
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
        statusArea.backgroundColor = .clear
        statusArea.layer.borderWidth = 0
        statusArea.layer.borderColor = UIColor.clear.cgColor
        timeElapsedLabel.text = ""
    }
}
