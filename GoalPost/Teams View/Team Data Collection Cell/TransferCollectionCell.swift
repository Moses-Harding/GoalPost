//
//  TransferCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation
import UIKit

class TransferCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamDataObject: TeamDataObject? { didSet { updateContent() } }
    
    // MARK: - Private Properties
    
    // Views
    let playerNameArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let transferFromTeam = UILabel()
    let transferToTeam = UILabel()
    let transferDate = UILabel()
    
    
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
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - TransferCollectionCell")
        mainStack.add([contentStack, loadingView])
        contentStack.add(children: [(UIView(), 0.05), (transferDate, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05),])
        bodyStack.add(children: [(UIView(), 0.025), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (transferFromTeam, nil), (UIView(), 0.1), (transferToTeam, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {

        // Labels
        transferDate.font = UIFont.preferredFont(forTextStyle: .title2)//UIFont.boldSystemFont(ofSize: 30)
        transferDate.numberOfLines = -1
        transferDate.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - TransferCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        playerNameLabel.textAlignment = .left
        
        transferToTeam.numberOfLines = -1
        
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
            guard let transferInfo = teamDataObject.transfer else { return }

            transferFromTeam.text = "From: \(transferInfo.teamFrom?.name ?? "-")"
            transferToTeam.text = "To: \(transferInfo.teamTo?.name ?? "-")"
            transferDate.text = transferInfo.transferDate.formatted(date: .numeric, time: .omitted)
            playerNameLabel.text = transferInfo.player?.name ?? "-"
        }
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        greenLine.backgroundColor = Colors.logoTheme
    }
}
