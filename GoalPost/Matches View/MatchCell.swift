//
//  MatchesViewListCell.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit

class MatchCell: UICollectionViewListCell {
    
    var match: MatchObject?
    
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

    init() {
        super.init(frame: .zero)
        
        setupAllViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    private func setStatus(from status: MatchStatusCode, time: Int?) {
        
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
    
    private func updateData(with match: MatchObject) {
        
        Task.init {

            guard let homeTeam = await match.homeTeam(), let awayTeam = await match.awayTeam() else { return }
            
            // Set data to UI elements
            homeTeamLabel.text = homeTeam.name
            awayTeamLabel.text = awayTeam.name
            startTimeLabel.text = match.timeStamp.formatted(date: .omitted, time: .shortened)
            homeTeamScore.text = String(match.homeTeamScore)
            awayTeamScore.text = String(match.awayTeamScore)
            setStatus(from: match.status, time: match.timeElapsed)
            
            vsLabel.text = "-"
            vsLabel.sizeToFit()
            //imageStack.layoutSubviews()
            
            loadImage(for: homeTeam, teamType: .home)
            loadImage(for: awayTeam, teamType: .away)
        }
    }
    
    enum TeamType {
        case home, away
    }
    
    private func loadImage(for team: TeamObject, teamType: TeamType) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        Task.init {
            if let image = await Cached.data.retrieveImage(from: imageName) {
                
                if teamType == .home {
                    self.homeImageView.image = image
                } else {
                    self.awayImageView.image = image
                }
                
                return
            }
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
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
}