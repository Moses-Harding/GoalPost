//
//  Teams View.swift
//  GoalPost
//
//  Created by Moses Harding on 5/10/22.
//

import Foundation
import UIKit

class TeamsView: UIView {
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var titleArea = UIStackView(.horizontal)
    var collectionViewArea = UIView()
    
    var collectionView: UICollectionView!
    
    var addTeamArea = UIStackView(.horizontal)
    var addTeamLabelView = UIView()

    // MARK: Buttons
    
    var addTeamButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ Add Teams", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(presentTeamSearchViewController), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        return button
    } ()
    
    // MARK: Labels
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Teams"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    } ()
    
    var favoriteTeamsLabel: UILabel = {
        let label = UILabel()
        label.text = "My Teams"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = -1
        return label
    } ()
    
    // MARK: Data
    
    var dataSource: UICollectionViewDiffableDataSource<Int, TeamSearchData>!
    
    // MARK: Gestures
    
    
    // MARK: Constraints
    
    // MARK: Logic
    var viewController: TeamsViewController?
    
    
    init() {
        super.init(frame: CGRect.zero)

        setUpMainStack()
        setUpAddTeamButton()
        setUpCollectionView()
        setUpColors()
        
        self.refresh()
        
        testing()
    }
    
    func testing() {
        //collectionViewArea.constrain(favoriteTeamsLabel)
        
        //self.refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    func setUpMainStack() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(titleArea, 0.075), (UIView(), 0.05), (addTeamArea, 0.1), (collectionViewArea, nil), (UIView(), 0.05)])
        
        // Might as well set up the title area as long as we're at it
        titleArea.constrain(titleLabel, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "My Teams Title Label")
    }
    
    func setUpAddTeamButton() {
        
        addTeamArea.add(children: [(UIView(), 0.25), (addTeamButton, 0.5), (UIView(), nil)])
        
        //addTeamLabelView.constrain(addTeamButton, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "Add Team Button")
    }
    
    func setUpCollectionView() {
        
        // MARK: Create list layout
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.showsSeparators = false
        layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
        layoutConfig.backgroundColor = Colors.backgroundColor
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: listLayout)
        collectionViewArea.constrain(collectionView, using: .edges, padding: 20)
        
        // MARK: Cell registration - What does the collectionview do to set up a cell - in this case simply passes data
        let cellRegistration = UICollectionView.CellRegistration<TeamCollectionCell, TeamSearchData>(handler: {
            (cell, indexPath, teamInformation) in
            
            cell.teamInformation = teamInformation
        })
            
        // MARK: Initialize data source - In order to initialize a datasource, you must pass a "Cell Provider" closure. This closure instructs the datasource what to do for each index
        dataSource = UICollectionViewDiffableDataSource<Int, TeamSearchData>(collectionView: collectionView) {
            (collectionView, indexPath, teamInformation) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: teamInformation)
        }
    }
    
    func setUpDataSourceSnapshots(searchResult: [TeamSearchData]?) {
        // MARK: Setup snap shots
        
        
        guard let result = searchResult else { return }
        
        let teams = result.map { $0 }

        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<Int, TeamSearchData>()
        snapshot.appendSections([0])
        snapshot.appendItems(teams, toSection: 0)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        titleArea.backgroundColor = Colors.titleAreaColor
        
        addTeamLabelView.backgroundColor = Colors.headerColor
        
        // Labels
        titleLabel.textColor = Colors.titleAreaTextColor
        
        // Buttons
        addTeamButton.backgroundColor = Colors.addButtonBackgroundColor
        addTeamButton.setTitleColor(Colors.addButtonTextColor, for: .normal)
        addTeamButton.layer.borderColor = Colors.addButtonBorderColor.cgColor
    }
}

// Actions

extension TeamsView {
    @objc func presentTeamSearchViewController() {
        
        if let controller = viewController {
            let teamsViewController = TeamsSearchViewController()
            teamsViewController.refreshableParent = self
            controller.present(teamsViewController, animated: true)
        }
    }
}


extension TeamsView: Refreshable  {
    
    // Refresh
    func refresh() {
        
        print("Refreshing")
        
        var foundTeams = [TeamSearchData]()
        
        for team in Cached.teams {
            if let teamSearchData = Cached.teamDictionary[team] {
                foundTeams.append(teamSearchData)
            }
        }
        
        setUpDataSourceSnapshots(searchResult: foundTeams)
    }
}
