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

class DEPRECATEDTeamCollectionCell: UICollectionViewCell {
    
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
    var removalButtonStack = UIStackView(.horizontal)
    var teamDataStack: DEPRECATEDTeamDataStack!
    
    var closedConstraint: NSLayoutConstraint?
    var openConstraint: NSLayoutConstraint?
    
    // Buttons
    let removalButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove Team", for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
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
        
        layer.cornerRadius = 8
        
        setUpMainStack()
        setUpTitleStack()
        setUpBodyStack()
        setUpColors()
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
    
    // 3
    func setUpBodyStack() {
        
        teamDataStack = DEPRECATEDTeamDataStack(team: self.teamInformation)
        bodyStack.add(children: [(UIView(), 0.05), (removalButtonStack, nil), (UIView(), 0.05), (teamDataStack, nil), (UIView(), 0.05)])
        
        removalButtonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        removalButtonStack.add(children: [(UIView(), 0.2), (removalButton, nil), (UIView(), 0.2)])
        
        bodyStack.isHidden = true
    }
    
    // 4
    func setUpColors() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = Colors.teamDataStackCellTextColor.cgColor
        self.layer.borderWidth = 1
        nameLabel.textColor = Colors.teamDataStackCellTextColor
        
        removalButton.backgroundColor = Colors.teamCellRemovalButtonBackgroundColor
        removalButton.layer.borderColor = Colors.teamCellRemovalButtonBorderColor.cgColor
        removalButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        
        if isSelected {
            self.openConstraint?.isActive = true
            self.closedConstraint?.isActive = false
            self.bodyStack.alpha = 1
            
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
                
            }) { _ in
                Task.init {
                    self.bodyStack.isHidden = false
                    await self.teamDataStack.manualRefresh()
                }
            }
            nameLabel.textColor = .white
        } else if !isSelected {
            self.openConstraint?.isActive = false
            self.closedConstraint?.isActive = true
            
            self.bodyStack.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bodyStack.isHidden = true
                self.layoutIfNeeded()
                
            })
            nameLabel.textColor = Colors.teamDataStackCellTextColor
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
            
            teamDataStack.team = teamInformation
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
        teamDataStack.clearCollectionView()
    }
}

extension DEPRECATEDTeamCollectionCell {
    @objc func removeTeam() {
        print("TeamCollectionCell - Removing team")
        guard let delegate = teamsViewDelegate, let team = self.teamInformation else { fatalError("No delegate passed to team collection cell") }

        delegate.remove(team: team)
    }
}
