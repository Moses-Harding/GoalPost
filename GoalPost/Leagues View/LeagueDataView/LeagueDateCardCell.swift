//
//  LeagueDateCardCell.swift
//  GoalPost
//
//  Created by Moses Harding on 9/1/22.
//

import Foundation
import UIKit

class LeagueDateCardCell: UICollectionViewCell {
    
    // MARK: UI
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    var contentStack = UIStackView(.vertical)
    
    // Views
    let leagueDateArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let leagueDateLabel = UILabel()
    let gamesCountLabel = UILabel()
    let matchesListLabel = UILabel()
    
    // MARK: Data
    
    var leagueDateObject: LeagueDateObject? { didSet { updateContent() } }
    
    var allLabels: [UILabel] {
        return [leagueDateLabel, gamesCountLabel]
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
        
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - LeagueDateCardCell")
        
        mainStack.add([contentStack])
        
        layer.cornerRadius = 15
        layer.borderColor = Colors.cellBorderGreen.cgColor
        layer.borderWidth = 1
        
        gamesCountLabel.textAlignment = .center
        
        contentStack.add(children: [(UIView(), 0.05), (leagueDateArea, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05)])
        bodyStack.add(children: [(UIView(), 0.125), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.125), (gamesCountLabel, nil), (UIView(), 0.05), (matchesListLabel, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {
        
        // Labels
        leagueDateArea.constrain(leagueDateLabel, debugName: "LeeagueDateLabel To LeagueNameArea - LeagueDateCardCell")
        
        leagueDateLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        leagueDateLabel.textAlignment = .center
        
        gamesCountLabel.numberOfLines = -1
        matchesListLabel.numberOfLines = -1
    }
    
    func updateContent() {
        
        guard let gamesCount = leagueDateObject?.gamesCountString, let date = leagueDateObject?.dateString, let matches = leagueDateObject?.matchIdsString else {
            print("LeagueDateCardCell - ERROR - Cannot update content")
            return
        }
        
        gamesCountLabel.text = gamesCount
        leagueDateLabel.text = date
        matchesListLabel.text = matches
        
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.cellBackgroundGray
        
        allLabels.forEach { $0.textColor = Colors.cellTextGreen }
        greenLine.backgroundColor = Colors.cellTextGreen
    }
}
