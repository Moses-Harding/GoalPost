//
//  LeagueDataView.swift
//  GoalPost
//
//  Created by Moses Harding on 8/30/22.
//

import Foundation
import UIKit

class LeagueDataView: UIView {
    

    var dataSource: UICollectionViewDiffableDataSource<TeamDataObjectType, LeagueDateObject>?
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
     
    let mainStack = UIStackView(.vertical)
    
    let nameArea = UIView()
    let removalButtonStack = UIStackView(.horizontal)
    let collectionViewArea = UIView()
    

    // Labels
    var nameLabel = UILabel()
    
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
        
        mainStack.add(children: [(UIView(), 0.05), (nameArea, 0.05), (UIView(), 0.05), (removalButtonStack, nil), (UIView(), 0.05), (collectionViewArea, nil), (UIView(), 0.05)])
        
        collectionViewArea.constrain(collectionView, using: .edges, padding: 5, debugName: "CollectionView to CollectionViewArea - LeagueDataView")
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - LeagueDataView")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        removalButtonStack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        removalButtonStack.add(children: [(UIView(), 0.2), (removalButton, nil), (UIView(), 0.2)])
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
        collectionView.register(LeagueDateCardCell.self, forCellWithReuseIdentifier: String(describing: LeagueDateCardCell.self))
        
        dataSource = UICollectionViewDiffableDataSource<TeamDataObjectType, LeagueDateObject>(collectionView: collectionView) {
            (collectionView, indexPath, leagueDateObject) -> UICollectionViewCell? in
            
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: LeagueDateCardCell.self),
                    for: indexPath) as? LeagueDateCardCell else {
                    fatalError("Could not cast cell as \(LeagueDateCardCell.self)")
                }
                
                cell.leagueDateObject = leagueDateObject
                return cell

        }
        collectionView.dataSource = dataSource
        
        // 3. Create a supplementary view registration. Generate a TitleSupplemenatryView, get the sectionIdentifier (e.g. .match), and set the label in the supplementaryView to the rawValue (in that case, "Matches"). Then provide this registration to the dataSource
        let supplementaryRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(elementKind: ElementKind.titleElementKind.rawValue) {
            (supplementaryView, elementKind, indexPath) in
            if let snapshot = self.dataSource?.snapshot() {
                let category = snapshot.sectionIdentifiers[indexPath.section]
                supplementaryView.label.text = category.rawValue
            }
        }
        
        dataSource?.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: supplementaryRegistration, for: index)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<TeamDataObjectType, LeagueDateObject>()
        snapshot.appendSections([.match])
        dataSource?.apply(snapshot)
        
    }
    
    // 3
    func setUpColors() {
        self.backgroundColor = Colors.cellBackgroundGray
        removalButton.backgroundColor = Colors.removalButtonBackgroundColor
        removalButton.layer.borderColor = Colors.removalButtonBorderColor.cgColor
        removalButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LeagueDataView {
    
    
    func updateContent() {
            guard let league = self.league else { return }
            self.nameLabel.text = league.name
            updateMatchSection()
    }
    
    func updateMatchSection() {
        /// Called when 1. the cell is selected or 2. when teamsView has called DataFetcher to retrieve info about a team, and that operation has completed
        /// Get all of the matches in the dictionary, create a TeamDataObject for each, then apply to datasource. (This triggers the creation of the matchCollectionCells)
        ///
        
        print("LeagueDataStack - Update Match Section for \(league?.name ?? "UKNOWN LEAGUE")")

        guard let dataSource = self.dataSource, let leagueId = self.league?.id, let matchIDs = QuickCache.helper.matchesByLeagueDictionary[leagueId] else { return }

        var snapshot = dataSource.snapshot(for: .match)

        var leagueDates = [LeagueDateObject]()
        
        var leagueDateDictionary = [Date:LeagueDateObject]()

        for matchId in matchIDs {
            
            guard let uniqueId = QuickCache.helper.matchIdDictionary[matchId], let matchDate = Double(String(uniqueId.split(separator: "|")[0])), let date = Date(timeIntervalSince1970: matchDate).removeTimeStamp else {
                print("LeagueDataView - Could not get date in updateMatchSection")
                continue
            }
            
            var leagueDateObject = leagueDateDictionary[date] ?? LeagueDateObject(date: date)
            leagueDateObject.matchIds.insert(matchId)
            leagueDateDictionary[date] = leagueDateObject
        }
        
        var position: Int = 0
        var index: Int = 0
        
        for (date, leagueDateObject) in leagueDateDictionary.sorted(by: { $0.key > $1.key }) {
            leagueDates.append(leagueDateObject)
                if date > Date.now {
                    position = index
                }
            index += 1
        }

        snapshot.applyDifferences(newItems: leagueDates)

        dataSource.apply(snapshot, to: .match, animatingDifferences: false)
        
        let indexPath = IndexPath(item: position, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
