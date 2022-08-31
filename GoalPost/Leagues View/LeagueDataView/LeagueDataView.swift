//
//  LeagueDataView.swift
//  GoalPost
//
//  Created by Moses Harding on 8/30/22.
//

import Foundation
import UIKit

class LeagueDataView: UIView {
    
    
    /*
    var dataSource: UICollectionViewDiffableDataSource<LeagueDataObjectType, ObjectContainer>?
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    */
     
    let mainStack = UIStackView(.vertical)
    
    let nameArea = UIView()
    let removalButtonStack = UIStackView(.horizontal)
    let collectionViewArea = UIView()
    

    // Labels
    var nameLabel = UILabel()
    
    //var totalHeight: CGFloat = 1200
    var totalHeight: CGFloat = 300
    
    // Data
    var league: LeagueObject? { didSet { updateContent() } }
    
    var viewController: LeagueDataViewController!
    
    // Buttons
    let removalButton: UIButton = {
        let button = UIButton()
        button.setTitle("Remove League", for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(removeLeague), for: .touchUpInside)
        return button
    } ()
    
    init() {
        super.init(frame: .zero)

        setUpMainStack()
        setUpCollectionView()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        // Set Up Structure

        self.constrain(mainStack)
        
        mainStack.add(children: [(UIView(), 0.05), (nameArea, 0.05), (UIView(), 0.05), (removalButtonStack, 0.1), (UIView(), 0.05), (collectionViewArea, nil), (UIView(), 0.05)])
        
        //collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - InjuryLeagueDataStack")
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - League Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        removalButtonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        removalButtonStack.add(children: [(UIView(), 0.2), (removalButton, nil), (UIView(), 0.2)])
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight).isActive = true
    }
    
    // 1.5 - Called when collectionView is accessed for the first time
    func createCollectionViewLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let titleHeight: CGFloat = 40
        let insetSize: CGFloat = 10
        let spacingSize: CGFloat = 5
        
        let cellSize: CGFloat = 200
        
        let sectionProvider = { (sectionIndex: Int,
                                 layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            // Set the size of the item to the size of its parent group
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Set the size of the group to  and absolute of 300 x 200
            let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(300),
                                                   heightDimension: .absolute(cellSize))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            // Add spacing / insets to the section, and indicate that it should scroll left-to-right
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.interGroupSpacing = spacingSize
            section.contentInsets = NSDirectionalEdgeInsets(top: insetSize, leading: insetSize, bottom: insetSize, trailing: insetSize)
            
            // Set the title dimensions to match the width of the group, with an estimated height of 40
            let titleSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .estimated(titleHeight))
            let titleSupplementary = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: titleSize,
                elementKind: ElementKind.titleElementKind.rawValue,
                alignment: .top)
            section.boundarySupplementaryItems = [titleSupplementary]
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        return layout
    }
    
    // 2
    func setUpCollectionView() {
        
    }
    
    // 3
    func setUpColors() {
        self.backgroundColor = Colors.teamCellViewBackgroundColor
        removalButton.backgroundColor = Colors.teamCellRemovalButtonBackgroundColor
        removalButton.layer.borderColor = Colors.teamCellRemovalButtonBorderColor.cgColor
        removalButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LeagueDataView {
    
    func updateContent() {

    }

    func clearCollectionView() {

    }
    
    func manualRefresh() async {

    }
    
}

extension LeagueDataView {
    @objc func removeLeague() {
        print("LeagueCollectionCell - Removing league")
        guard let delegate = viewController.leaguesViewDelegate, let league = self.league, let viewController = self.viewController else { fatalError("No delegate passed to league collection cell") }

        viewController.dismiss(animated: true)
        delegate.remove(league: league)
    }
}
