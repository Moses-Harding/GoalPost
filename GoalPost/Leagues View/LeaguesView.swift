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
    
    // Collection View
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    // Stack View
    var mainStack = UIStackView(.vertical)
    var titleArea = UIStackView(.horizontal)
    var addLeagueStack = UIStackView(.horizontal)
    var addLeagueLabelView = UIView()
    
    // MARK: Buttons
    
    var addLeagueButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ Add Leagues", for: .normal)
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
    
    // MARK: Logic
    
    var viewController: LeaguesViewController?
    
    // MARK: Data
    
    var dataSource: UICollectionViewDiffableDataSource<Section, LeagueObject>?
    
    
    init() {
        super.init(frame: CGRect.zero)
        setUpStacks()
        setUpCollectionView()
        setUpDataSource()
        setUpColors()
        collectionView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Set Up
    
    // 1
    private func setUpStacks() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(titleArea, 0.075), (UIView(), 0.025), (addLeagueStack, 0.1), (UIView(), 0.025), (collectionView, nil), (UIView(), 0.05)])
        
        // Might as well set up the title area as long as we're at it
        titleArea.constrain(titleLabel, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "My Leagues Title Label")
        
        addLeagueStack.add(children: [(UIView(), 0.25), (addLeagueButton, nil), (UIView(), 0.25)])
    }
    
    // 2
    private func setUpCollectionView() {
        collectionView.register(LeagueCollectionCell.self, forCellWithReuseIdentifier: String(describing: LeagueCollectionCell.self))
    }
    
    // 2.5 - Called via lazy initialization of collectionview
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let padding: CGFloat = 0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(50))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 20
        section.contentInsets = .init(top: 20, leading: padding, bottom: padding, trailing: padding)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // 3
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
            cell.leaguesViewDelegate = self
            return cell
        }
        
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, LeagueObject>()
        snapshot.appendSections([.main])
        dataSource?.apply(snapshot)
    }
    
    // 4
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        titleArea.backgroundColor = Colors.titleAreaColor
        collectionView.backgroundColor = Colors.backgroundColor
        
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


extension LeaguesView: LeaguesViewDelegate  {
    func refresh(calledBy function: String) {
        
        print("LeaguesView - Refreshing - called by \(function)")
        
        
        // 1. Retrieve all leagues from cache. It must be async to deal with concurrency issues.
        var foundLeagues = [LeagueObject]()
        
        for league in QuickCache.helper.favoriteLeaguesDictionary.sorted(by: { $0.value.name < $1.value.name }) {
            foundLeagues.append(league.value)
        }
        
        guard let dataSource = dataSource else { return }
        
        // 2. Create a new snapshot using .main and append the leagues that were found
        
        var snapShot = dataSource.snapshot(for: .main)
        
        snapShot.applyDifferences(newItems: foundLeagues)
        
        // 3. Apply to datasource
        dataSource.apply(snapShot, to: .main, animatingDifferences: true)
    }
    
    func remove(league: LeagueObject) {
        Task.init {
            await Cached.data.favoriteLeaguesRemoveValue(forKey: league.id)
                guard let dataSource = self.dataSource else { return }
                
                var snapShot = dataSource.snapshot(for: .main)
                snapShot.delete([league])
                
                // 3. Apply to datasource
                await dataSource.apply(snapShot, to: .main, animatingDifferences: true)
            }
    }
    
    func present(_ viewController: UIViewController, completion: (() -> Void)?) {
        self.viewController?.present(viewController, animated: true, completion: completion)
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

extension LeaguesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let dataSource = dataSource else { return false }
        
        // Allows for closing an already open cell
        if collectionView.indexPathsForSelectedItems?.contains(indexPath) ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
        }
        
        dataSource.refresh()
        
        return false // The selecting or deselecting is already performed above
    }
}
