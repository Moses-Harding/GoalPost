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
    var statusStack = UIStackView(.horizontal)
    var statusArea = UIView()
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAllViews()
    }
    
    private func setupAllViews() {
        
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        mainStack.add([separator, topStack, bottomStack])
        
        topStack.heightAnchor.constraint(equalTo: bottomStack.heightAnchor).isActive = true
        topStack.heightAnchor.constraint(greaterThanOrEqualToConstant: 35).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

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
        
        statusStack.add(children: [(UIView(), nil), (statusArea, nil), (UIView(), nil)])
        statusStack.distribution = .equalCentering
        statusArea.constrain(timeElapsedLabel, using: .scale, heightScale: 1.0, padding: 0, except: [.width], safeAreaLayout: false, debugName: "Time Elapsed Outline Constraining TIme Elapsed Label")
        statusArea.heightAnchor.constraint(equalTo: statusStack.heightAnchor, multiplier: 0.8).isActive = true
        statusArea.layer.borderColor = Colors.titleAreaTextColor.cgColor
        statusArea.layer.borderWidth = 1
        statusArea.layer.cornerRadius = 10
        statusArea.widthAnchor.constraint(equalTo: timeElapsedLabel.widthAnchor, multiplier: 2).isActive = true
        
        // MARK: Set up image stack
        
        homeImage.constrain(homeImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Home Image View")
        
        
        awayImage.constrain(awayImageView, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Away Image View")
        
        imageStack.alignment = .center
        
        refreshCell()
    }
    
    func refreshCell() {
        
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

        var backgroundColor = UIColor.clear
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
        case .finished:
            backgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        case .finishedAfterPenalties:
            backgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        case .finishedAfterExtraTime:
            backgroundColor = Colors.titleAreaColor
            timeElapsed = "FT"
        default:
            timeElapsed = " " + String(time) + " "
            borderWidth = 1
            borderColor = Colors.cellSecondaryTextColor
        }
        
        statusArea.backgroundColor = backgroundColor
        statusArea.layer.borderWidth = borderWidth
        statusArea.layer.borderColor = borderColor.cgColor
        timeElapsedLabel.text = timeElapsed
    }
    
    func updateData() {
        
        guard let match = objectContainer?.match, let homeTeam = match.homeTeam, let awayTeam = match.awayTeam else { return }
        
        var newMatch: Bool = false
        
        
        if let oldObjectContainer = oldObjectContainer, let newObjectContainer = objectContainer, oldObjectContainer == newObjectContainer {
                print("MatchCell - Cell is the same")
            newMatch = false
        } else {
            newMatch = true
        }
        
        oldObjectContainer = objectContainer
        
        refreshCell()
        
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
