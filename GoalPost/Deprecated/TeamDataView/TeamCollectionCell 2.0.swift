//
//  TeamCollectionCell 2.0.swift
//  GoalPost
//
//  Created by Moses Harding on 8/15/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 TeamCollectionCell contains information about a team, a button that removes the team from favorites, and a collapsible section that contains a TeamDataStack (which contains data such as Match information). The TeamDataStack shows or hides based off of "isSelected". The other data is populated when the "teamInformation" is sset.
 
 1. SetUp - UI (title, button, body is set up)
 2. TeamsView registers TeamCollectionCell, then assigns a teamObject to the teamInformation variable. This triggeres "updateContent", which populates the label and image.
 3. When the cell is tapped, "isSelected" is triggered, which triggers updateAppearance. If selected, bodyStack is unhidden and the contentView is contrained to the bottom of it. If !isSelected, the bodyStack is hidden (alpha first, then hidden) and the contentView is constrained to the titleStack
 4. If the remove button is tapped, teamsView (which is a delegate) triggers the remove(team) method.
 
 contentView
    mainStack
        titleStack
            nameArea --- nameLogo
        bodyStack
            removalButton
            teamDataStack
 */

class TeamCollectionCell2: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamInformation: TeamObject? { didSet { updateContent() } }
    var teamsViewDelegate: TeamsViewDelegate?
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    
    // Views
    let logoArea = UIView()
    let nameArea = UIView()
    
    // Labels
    let nameLabel = UILabel()
    let foundedLabel = UILabel()
    let countryLabel = UILabel()
    let codeLabel = UILabel()
    let nationalLabel = UILabel()
    
    // Image
    let teamLogo = UIImageView()
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    
    var titleStack = UIStackView(.horizontal)
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Set Up
    
    func setUp() {
        
        layer.cornerRadius = 8
        
        setUpMainStack()
        setUpTitleStack()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        let padding: CGFloat = 5
        contentView.constrain(mainStack, using: .edges, padding: padding, except: [.bottom], debugName: "Main Stack to Content View - Team Collection Cell")
        mainStack.add([titleStack])
    }
    
    // 2
    func setUpTitleStack() {
        titleStack.add(children: [(UIView(), 0.05), (nameArea, 0.8), (UIView(), nil), (logoArea, nil), (UIView(), 0.05)])
        titleStack.alignment = .center
        
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - Team Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        logoArea.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoArea.constrain(teamLogo, except: [.height, .width], debugName: "TeamLogo to Logo Area - Team Collection Cell")
        teamLogo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        teamLogo.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }

    
    // 4
    func setUpColors() {
        self.backgroundColor = Colors.teamCellViewBackgroundColor
        nameLabel.textColor = .white
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        
        if isSelected {
            let viewController = TeamDataViewController()
            teamsViewDelegate?.present(viewController) {
                viewController.teamDataView.team = self.teamInformation
                viewController.teamsViewDelegate = self.teamsViewDelegate
            }
        } else {
            print("Not selected")
        }
    }
    
    func updateContent() {
        
        guard let teamInfo = teamInformation else { return }
        Task.init {
            nameLabel.text = teamInfo.name
            foundedLabel.text = "Founded: \(teamInfo.founded ?? 0)"
            countryLabel.text = "Country: \(teamInfo.country ?? "")"
            codeLabel.text = "Code: \(teamInfo.code ?? "")"
            nationalLabel.text = "National: \(teamInfo.national)"
            
            await loadImage(for: teamInfo)
        }
    }
    
    func loadImage(for team: TeamObject) async {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        
        if let image = await Cached.data.retrieveImage(from: imageName) {
            
            self.teamLogo.image = image
            
            return
        }
        
        guard let url = URL(string: team.logo!) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.teamLogo.image = image
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {

    }
}
