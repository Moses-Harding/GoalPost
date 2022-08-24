//
//  Leagues View.swift
//  GoalPost
//
//  Created by Moses Harding on 5/10/22.
//

import Foundation
import UIKit

class LeaguesView: UIView {
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var titleArea = UIStackView(.horizontal)
    var collectionViewArea = UIView()
    
    var collectionView: UICollectionView!
    
    var addLeagueArea = UIStackView(.horizontal)
    var addLeagueLabelView = UIView()
    
    // MARK: Buttons
    
    var addLeagueButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ Add Leagues ", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(presentLeagueSearchViewController), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 2
        return button
    } ()
    
    // MARK: Labels
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Leagues"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    } ()
    
    var favoriteLeaguesLabel: UILabel = {
        let label = UILabel()
        label.text = "My Leagues"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.numberOfLines = -1
        return label
    } ()
    
    // MARK: Data
    
    var dataSource: UICollectionViewDiffableDataSource<Section, LeagueObject>!
    
    // MARK: Gestures
    
    
    // MARK: Constraints
    
    // MARK: Logic
    var viewController: LeaguesViewController?
    
    
    init() {
        super.init(frame: CGRect.zero)
        
        setUpMainStack()
        setUpAddLeagueButton()
        setUpCollectionView()
        setUpDataSource()
        setUpColors()
        
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    func setUpMainStack() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(titleArea, 0.075), (UIView(), 0.05), (addLeagueArea, 0.1), (collectionViewArea, nil), (UIView(), 0.05)])
        
        // Might as well set up the title area as long as we're at it
        titleArea.constrain(titleLabel, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "My Leagues Title Label")
    }
    
    func setUpAddLeagueButton() {
        
        addLeagueArea.add(children: [(UIView(), 0.25), (addLeagueButton, 0.5), (UIView(), nil)])
        
        //addLeagueLabelView.constrain(addLeagueButton, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "Add League Button")
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
        
        collectionView.register(LeagueCollectionCell.self, forCellWithReuseIdentifier: String(describing: LeagueCollectionCell.self))
    }
    
    private func setUpDataSource() {
        
        print("LeaguesView - setUpDataSource")
        
        dataSource = UICollectionViewDiffableDataSource<Section, LeagueObject>(collectionView: collectionView) {
            (collectionView, indexPath, leagueInformation) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: LeagueCollectionCell.self),
                for: indexPath) as? LeagueCollectionCell else {
                fatalError("Could not cast cell as \(LeagueCollectionCell.self)")
            }
            cell.leagueInformation = leagueInformation
            return cell
        }
        
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, LeagueObject>()
        snapshot.appendSections([.main])
        dataSource?.apply(snapshot)
    }
    
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        titleArea.backgroundColor = Colors.titleAreaColor
        
        addLeagueLabelView.backgroundColor = Colors.headerColor
        
        // Labels
        titleLabel.textColor = Colors.titleAreaTextColor
        
        // Buttons
        addLeagueButton.backgroundColor = Colors.addButtonBackgroundColor
        addLeagueButton.setTitleColor(Colors.addButtonTextColor, for: .normal)
        addLeagueButton.layer.borderColor = Colors.addButtonBorderColor.cgColor
    }
}

// Actions

extension LeaguesView {
    @objc func presentLeagueSearchViewController() {
        
        if let controller = viewController {
            let leagueSearchViewController = LeagueSearchViewController()
            leagueSearchViewController.delegate = self
            controller.present(leagueSearchViewController, animated: true)
        }
    }
}


extension LeaguesView: LeagueSearchDelegate  {
    
    // Refresh
    func refresh() {
        
        print("LeaguesView - Refreshing")
        
        
        // 1. Retrieve all teams from cache. It must be async to deal with concurrency issues.
        var foundLeagues = [LeagueObject]()
        
        for league in QuickCache.helper.favoriteLeaguesDictionary.sorted(by: { $0.value.name < $1.value.name }) {
            foundLeagues.append(league.value)
        }
        
        guard let dataSource = dataSource else { return }
        
        // 2. Create a new snapshot using .main and append the teams that were found
        
        var snapShot = dataSource.snapshot(for: .main)
        
        snapShot.applyDifferences(newItems: foundLeagues)
        
        // 3. Apply to datasource
        dataSource.apply(snapShot, to: .main, animatingDifferences: true)
    }
    
    
    func add(league: LeagueObject) {
        // MARK: Setup snap shots
        guard let dataSource = dataSource else { return }
        
        var snapshot = dataSource.snapshot(for: .main)
        
        let newItems = (snapshot.items + [league]).sorted(by: {$0.name < $1.name})
        
        snapshot.applyDifferences(newItems: newItems)
        
        dataSource.apply(snapshot, to: .main, animatingDifferences: true)
        
        Task.init {
            await Cached.data.set(.favoriteLeaguesDictionary, with: league.id, to: league)
        }
    }
}
