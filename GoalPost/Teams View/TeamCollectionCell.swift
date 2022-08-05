//
//  TeamsCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/16/22.
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

class TeamCollectionCell: UICollectionViewCell {
    
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
    
    var bodyStack = UIStackView(.vertical)
    var teamDataStack: TeamDataStack!
    
    var closedConstraint: NSLayoutConstraint?
    var openConstraint: NSLayoutConstraint?
    
    // Buttons
    let removalButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove Team", for: .normal)
        button.backgroundColor = Colors.teamCellRemovalButtonBackgroundColor
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(removeTeam), for: .touchUpInside)
        return button
    } ()
    
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
        
        self.backgroundColor = Colors.teamCellViewBackgroundColor
        layer.cornerRadius = 8
        
        setUpMainStack()
        setUpTitleStack()
        setUpBodyStack()
    }
    
    // 1
    func setUpMainStack() {
        let padding: CGFloat = 5
        contentView.constrain(mainStack, using: .edges, padding: padding, except: [.bottom], debugName: "Main Stack to Content View - Team Collection Cell")
        mainStack.add([titleStack, bodyStack])
        
        closedConstraint =
        titleStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
        bodyStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: padding)
        openConstraint?.priority = .defaultLow
        
        closedConstraint?.isActive = true
    }
    
    // 2
    func setUpTitleStack() {
        titleStack.add(children: [(nameArea, 0.8), (UIView(), nil), (logoArea, nil)])
        titleStack.alignment = .center
        
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - Team Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        logoArea.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoArea.constrain(teamLogo, except: [.height, .width], debugName: "TeamLogo to Logo Area - Team Collection Cell")
        teamLogo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        teamLogo.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // 3
    func setUpBodyStack() {
        
        teamDataStack = TeamDataStack(team: self.teamInformation)
        bodyStack.add(children: [(UIView(), 0.05), (removalButton, nil), (UIView(), 0.05), (teamDataStack, nil), (UIView(), 0.05)])
        
        removalButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        bodyStack.isHidden = true
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        
        if isSelected {
            self.teamDataStack.manualRefresh()
        }
        
        if isSelected {
            self.openConstraint?.isActive = true
            self.closedConstraint?.isActive = false
            self.bodyStack.alpha = 1
            
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
                
            }) { _ in
                self.bodyStack.isHidden = !self.isSelected
            }
        } else if !isSelected {
            self.openConstraint?.isActive = false
            self.closedConstraint?.isActive = true
            
            self.bodyStack.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bodyStack.isHidden = true
                self.layoutIfNeeded()
                
            })
        }
    }
    
    func updateContent() {
        
        guard let teamInfo = teamInformation else { return }
        nameLabel.text = teamInfo.name
        foundedLabel.text = "Founded: \(teamInfo.founded ?? 0)"
        countryLabel.text = "Country: \(teamInfo.country ?? "")"
        codeLabel.text = "Code: \(teamInfo.code ?? "")"
        nationalLabel.text = "National: \(teamInfo.national)"
        
        loadImage(for: teamInfo)
        
        // DispatchQueue.main.async { [self] in
            teamDataStack.team = teamInformation
        // }
    }
    
    func loadImage(for team: TeamObject) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        Task.init {
            if let image = await Cached.data.retrieveImage(from: imageName) {
                
                self.teamLogo.image = image
                
                return
            }
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
}

extension TeamCollectionCell {
    @objc func removeTeam() {
        print("TeamCollectionCell - Removing team")
        guard let delegate = teamsViewDelegate, let team = self.teamInformation else { fatalError("No delegate passed to team collection cell") }
        delegate.remove(team: team)
    }
}
