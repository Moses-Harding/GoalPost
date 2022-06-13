//
//  MatchCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit
/*
class MatchCollectionCell: TeamDataStackCellModel {
    
    // MARK: - Data
    
    var teamDataObject: TeamDataObject? { didSet { updateContent() } }
    
    // MARK: - Indicator
    
    var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        return view
    } ()
    
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
    
    var mainStack = UIStackView(.vertical)
    var contentStack = UIStackView(.vertical)
    
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
    
    let greenLine = UIView()
    
    // Loading
    var loadingView = UIView()
    var loadingLabel = UILabel()
    
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
        
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - MatchCollectionCell")
        
        mainStack.add([contentStack, loadingView])
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
        
        imageStack.alignment = .center
        
        loadingView.constrain(loadingLabel, debugName: "Loading Label to Loading View - MatchCollectionCell")
        
        loadingLabel.text = "LOADING"
        loadingLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        loadingLabel.textAlignment = .center
        loadingView.isHidden = true
    }
    
    func updateContent() {
        
        guard let teamDataObject = teamDataObject else { return }
        
        if teamDataObject.loading {
            loadingView.isHidden = false
            contentStack.isHidden = true
            self.loading(true)
        } else {
            loadingView.isHidden = true
            contentStack.isHidden = false
            self.loading(false)

            guard let match = teamDataObject.match else { print("Attempting to update content for match cell but matchInformation not found")
                return
            }
            guard let homeTeam = Cached.teamDictionary[match.homeTeamId] else { print("Attempting to update content for match cell but home team with id \(match.homeTeamId) not found")
                return
            }
            guard let awayTeam = match.awayTeam else { print("Attempting to update content for match cell but away Team with id \(match.awayTeamId) not found")
                return
            }
        
        // Set data to UI elements
        homeTeamLabel.text = homeTeam.name
        awayTeamLabel.text = awayTeam.name
        dateLabel.text = match.timeStamp.formatted(date: .numeric, time: .omitted)
        homeTeamScore.text = String(match.homeTeamScore)
        awayTeamScore.text = String(match.awayTeamScore)
        
        loadImage(for: homeTeam, teamType: .home)
        loadImage(for: awayTeam, teamType: .away)
        }
    }
    
    enum TeamType {
        case home, away
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        self.layer.cornerRadius = 10
        greenLine.backgroundColor = Colors.logoTheme
    }
    
    func loading(_ loading: Bool) {
        if loading {
            self.backgroundColor = UIColor.clear
            self.indicator.startAnimating()
            UIView.animate(withDuration: 1.0, delay: 0, options: [.repeat, .autoreverse]) {
                self.loadingLabel.layer.backgroundColor = UIColor.blue.cgColor
                
            }
        } else {
            self.backgroundColor = Colors.teamDataStackCellBackgroundColor
            self.indicator.stopAnimating()
        }

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
*/

class MatchCollectionCell: TeamDataStackCellModel {
    
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
    }
    
    // MARK: - Private Methods
    private func setUp() {

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
        
        imageStack.alignment = .center
    }
    
    override func updateContent() {
        
        guard let teamDataObject = teamDataObject else { return }

            guard let match = teamDataObject.match else { print("Attempting to update content for match cell but matchInformation not found")
                return
            }
            guard let homeTeam = Cached.teamDictionary[match.homeTeamId] else { print("Attempting to update content for match cell but home team with id \(match.homeTeamId) not found")
                return
            }
            guard let awayTeam = match.awayTeam else { print("Attempting to update content for match cell but away Team with id \(match.awayTeamId) not found")
                return
            }
        
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
        greenLine.backgroundColor = Colors.logoTheme
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
