//
//  TransferCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation
import UIKit

class TransferCollectionCell: TeamDataStackCellModel {
    
    
    // MARK: - Private Properties
    
    // Views
    let playerNameArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let transferFromTeam = UILabel()
    let transferToTeam = UILabel()
    let transferDate = UILabel()
    
    var allLabels: [UILabel] {
        return [playerNameLabel, transferFromTeam, transferToTeam, transferDate]
    }

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

        setUpStacks()
        setUpViewContent()
        setUpColors()

    }
    
    func setUpStacks() {

        contentStack.add(children: [(UIView(), 0.05), (transferDate, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05),])
        bodyStack.add(children: [(UIView(), 0.025), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (transferFromTeam, nil), (UIView(), 0.1), (transferToTeam, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {

        // Labels
        transferDate.font = UIFont.preferredFont(forTextStyle: .title2)
        transferDate.numberOfLines = -1
        transferDate.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - TransferCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        playerNameLabel.textAlignment = .left
        
        transferToTeam.numberOfLines = -1
    }

    override func updateContent() {
        
        Task.init {
            guard let teamDataObject = teamDataObject, let transferInfo = await teamDataObject.transfer() else { return }

            transferFromTeam.text = "From: \(await transferInfo.teamFrom()?.name ?? "-")"
            transferToTeam.text = "To: \(await transferInfo.teamTo()?.name ?? "-")"
            transferDate.text = transferInfo.transferDate.formatted(date: .numeric, time: .omitted)
            playerNameLabel.text = await transferInfo.player()?.name ?? "-"
        }
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        
        allLabels.forEach { $0.textColor = Colors.teamDataStackCellTextColor }
        greenLine.backgroundColor = Colors.teamDataStackCellTextColor
    }
}

