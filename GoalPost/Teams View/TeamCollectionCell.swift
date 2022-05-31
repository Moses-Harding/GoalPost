//
//  TeamsCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/16/22.
//

import Foundation
import UIKit

/*
 
 CELL BODY
 
 ____________________________________
 | CONTENT VIEW                       |
 |   ______________________________   |
 |  | MAIN STACK                   |  |
 |  |   _______________________    |  |
 |  |  | TITLE STACK           |   |  |
 |  |  |  __________________   |   |  |
 |  |  | |NAME LABEL | LOGO |  |   |  |
 |  |  | |___________|______|  |   |  |
 |  |  |_______________________|   |  |
 |  |                              |  |
 |  |   ________________________   |  |
 |  |  | BODY STACK             |  |  |
 |  |  |  ____________________  |  |  |
 |  |  | | MATCHES STACK      | |  |  |
 |  |  | |  ________________  | |  |  |
 |  |  | | |  MATCHES LABEL | | |  |  |
 |  |  | | |  -----------   | | |  |  |
 |  |  | | | COLLECTIONVIEW | | |  |  |
 |  |  | | |________________| | |  |  |
 |  |  | | ------------------ | |  |  |
 |  |  | | SQUAD STACK        | |  |  |
 |  |  | |  ________________  | |  |  |
 |  |  | | | SQUAD LABEL    | | |  |  |
 |  |  | | |  -----------   | | |  |  |
 |  |  | | | COLLECTIONVIEW | | |  |  |
 |  |  | | |________________| | |  |  |
 |  |  | | ------------------ | |  |  |
 |  |  | | INJURIES STACK     | |  |  |
 |  |  | |  ________________  | |  |  |
 |  |  | | | INJURIES LABEL | | |  |  |
 |  |  | | |  -----------   | | |  |  |
 |  |  | | | COLLECTIONVIEW | | |  |  |
 |  |  | | |________________| | |  |  |
 |  |  | | ------------------ | |  |  |
 |  |  | | TRANSFERS STACK    | |  |  |
 |  |  | |  ________________  | |  |  |
 |  |  | | | TRANSFERS LABEL| | |  |  |
 |  |  | | |  -----------   | | |  |  |
 |  |  | | | COLLECTIONVIEW | | |  |  |
 |  |  | | |________________| | |  |  |
 |  |  | |____________________| |  |  |
 |  |  |________________________|  |  |
 |  |______________________________|  |
 |____________________________________|
 
 */


class TeamCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamInformation: TeamObject? { didSet { updateContent() } }
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
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    
    func setUp() {
        self.backgroundColor = Colors.teamCellViewBackgroundColor
        layer.cornerRadius = 8
        
        setUpMainStack()
        setUpTitleStack()
        setUpBodyStack()
        
        // TEMPORARY
    }
    
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
    
    func setUpBodyStack() {

        teamDataStack = TeamDataStack(team: self.teamInformation)
        bodyStack.addArrangedSubview(teamDataStack)
        
        bodyStack.isHidden = true
    }
    
    func updateContent() {
        guard let teamInfo = teamInformation else { return }
        nameLabel.text = teamInfo.name
        foundedLabel.text = "Founded: \(teamInfo.founded ?? 0)"
        countryLabel.text = "Country: \(teamInfo.country ?? "")"
        codeLabel.text = "Code: \(teamInfo.code ?? "")"
        nationalLabel.text = "National: \(teamInfo.national)"
        
        loadImage(for: teamInfo)
        
        DispatchQueue.main.async { [self] in
            teamDataStack.team = teamInformation
            teamDataStack.refresh()
        }
    }
    
    func updateAppearance() {
        
        if isSelected {
            DispatchQueue.main.async {
                self.teamDataStack.refresh()
            }
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
        } else {
            self.openConstraint?.isActive = false
            self.closedConstraint?.isActive = true
            
            self.bodyStack.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                self.bodyStack.isHidden = true
                self.layoutIfNeeded()
                
            })
        }
    }
    
    func loadImage(for team: TeamObject) {
        
        let imageName = "\(team.name) - \(team.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            self.teamLogo.image = image
            
            return
        }
        
        guard let url = URL(string: team.logo!) else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.teamLogo.image = image
                    
                    Cached.data.save(image: image, uniqueName: imageName)
                }
            }
        }
    }
}
