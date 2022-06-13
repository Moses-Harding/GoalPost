//
//  InjuryCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/30/22.
//

import Foundation
import UIKit

/*
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
    var contentStack = UIStackView(.vertical)

    var bodyStack = UIStackView(.horizontal)
    var descriptionStack = UIStackView(.vertical)

    // Loading
    var loadingView = UIView()
    var loadingLabel = UILabel()
    
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
        mainStack.add([contentStack, loadingView])
        contentStack.add(children: [(UIView(), 0.05), (timeOfInjuryLabel, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05)])
        bodyStack.add(children: [(UIView(), 0.025), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (reasonLabel, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {
        
        // Labels
        timeOfInjuryLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        timeOfInjuryLabel.numberOfLines = -1
        timeOfInjuryLabel.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - InjuryCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        playerNameLabel.textAlignment = .left
        
        reasonLabel.numberOfLines = -1
        
        loadingView.constrain(loadingLabel, debugName: "Loading Label to Loading View - InjuryCollectionCell")
        loadingLabel.text = "LOADING"
        loadingView.isHidden = true
    }

    func updateContent() {
        
        guard let teamDataObject = teamDataObject else { return }
        
        if teamDataObject.loading {
            loadingView.isHidden = false
            contentStack.isHidden = true
        } else {
            loadingView.isHidden = true
            contentStack.isHidden = false
            
            guard let injuryInfo = teamDataObject.injury else { return }
            
            reasonLabel.text = "\(injuryInfo.reason)"
            timeOfInjuryLabel.text = "\(injuryInfo.date.formatted(date: .numeric, time: .omitted))"
            playerNameLabel.text = injuryInfo.player?.name ?? "CANNOT LOCATE PLAYER"
        }
    }

    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        greenLine.backgroundColor = Colors.logoTheme
    }
}
*/

class InjuryCollectionCell: TeamDataStackCellModel {
    
    // MARK: - Private Properties
    
    // Views
    let playerNameArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let reasonLabel = UILabel()
    let timeOfInjuryLabel = UILabel()

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

        contentStack.add(children: [(UIView(), 0.05), (timeOfInjuryLabel, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05)])
        bodyStack.add(children: [(UIView(), 0.025), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (reasonLabel, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {
        
        // Labels
        timeOfInjuryLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        timeOfInjuryLabel.numberOfLines = -1
        timeOfInjuryLabel.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - InjuryCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        playerNameLabel.textAlignment = .left
        
        reasonLabel.numberOfLines = -1
    }

    override func updateContent() {
        
        guard let teamDataObject = teamDataObject else { return }
            guard let injuryInfo = teamDataObject.injury else { return }
            
            reasonLabel.text = "\(injuryInfo.reason)"
            timeOfInjuryLabel.text = "\(injuryInfo.date.formatted(date: .numeric, time: .omitted))"
            playerNameLabel.text = injuryInfo.player?.name ?? "CANNOT LOCATE PLAYER"
    }

    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        greenLine.backgroundColor = Colors.logoTheme
    }
}
