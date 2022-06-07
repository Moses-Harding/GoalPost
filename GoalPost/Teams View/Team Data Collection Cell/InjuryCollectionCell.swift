//
//  InjuryCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

class InjuryCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamDataObject: TeamDataObject? { didSet { updateContent() } }
    
    // MARK: - Private Properties
    
    // Views
    let playerNameArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let reasonLabel = UILabel()
    let timeOfInjuryLabel = UILabel()

    // Stacks
    var mainStack = UIStackView(.vertical)
    
    //var titleStack = UIStackView(.vertical)
    var bodyStack = UIStackView(.horizontal)
    var descriptionStack = UIStackView(.vertical)

    
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
        layer.cornerRadius = 15

        setUpStacks()
        setUpViewContent()
        setUpColors()

    }
    
    func setUpStacks() {
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - InjuryCollectionCell")
        mainStack.add(children: [(UIView(), 0.05), (timeOfInjuryLabel, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05),])
        bodyStack.add(children: [(UIView(), 0.025), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (reasonLabel, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {
        
        // Labels
        timeOfInjuryLabel.font = UIFont.preferredFont(forTextStyle: .title2)//UIFont.boldSystemFont(ofSize: 30)
        timeOfInjuryLabel.numberOfLines = -1
        timeOfInjuryLabel.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - InjuryCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)//UIFont.boldSystemFont(ofSize: 24)
        playerNameLabel.textAlignment = .left
        
        reasonLabel.numberOfLines = -1

    }

    func updateContent() {
        guard let injuryInfo = teamDataObject?.injury else { return }
        reasonLabel.text = "\(injuryInfo.reason)"
        if let match = injuryInfo.match {
            timeOfInjuryLabel.text = "\(DateFormatter.localizedString(from: match.timeStamp, dateStyle: .short, timeStyle: .none))"
        }
        if let player = injuryInfo.player {
            playerNameLabel.text = player.name
        }
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        greenLine.backgroundColor = Colors.logoTheme
        //self.layer.borderColor = Colors.logoTheme.cgColor
        //self.layer.borderWidth = 1
    }
}
