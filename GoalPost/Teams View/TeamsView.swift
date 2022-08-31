//
//  Teams View.swift
//  GoalPost
//
//  Created by Moses Harding on 5/10/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 TeamsView includes each team that is added to favorites, as well as a button that triggers TeamSearchView (which searches for / adds additional teams). Each team from favorites is given a cell called TeamCollectionCell, which includes a TeamDataStack. This in turn includes data abotu different categories, e.g. Match, Transfer, Injury, Player.
 
 Set Up Sequence
 1. TeamsViewController loads TeamsView
 2. TeamsView init sets up UI
 3. TeamsView init sets up collectionview / datasource, registering TeamCollectionCell with one section (.main)
 4. View appears and Refresh is called, grabbing data for all favorite teams and applying to datasource
 
 External Triggers
 - Refresh: Called when view appears, when a team is added, and when a team is removed. This searches through favorite teams, then adds their data to the collectionview's datasource and applies it, replacing existing cells.
 - Add: When a cell is selected in TeamSearchView, an animation plays and then add() is called. A new cell is inserted into the existing snapshot and that cell is passed to the DataFetcher, which retrieves information about the team and adds it favorites. Once that information is retrieved, the cell's data is updated via cell-specific methods.
 - Remove: Called by removal button for a given team collection cell. Removes team from favorites and then simply called Refresh
 - PresentTeamSearchViewController: The "+ Add Teams" button presents the TeamSearchViewController
 
 
 --------
 TitleStack
 Add Button
 --------
 CollectionView
 TeamCollectionCell
 TeamDataStack
 CollectionView
 TitleSupplementaryView
 MatchCollectionCell
 */

class TeamsView: UIView {
    
    
    // MARK: Views
    
    // Collection View
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    // Stack View
    var mainStack = UIStackView(.vertical)
    var titleArea = UIStackView(.horizontal)
    var addTeamStack = UIStackView(.horizontal)
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
    
    // MARK: Logic
    
    var viewController: TeamsViewController?
    
    // MARK: Data
    
    var dataSource: UICollectionViewDiffableDataSource<Section, TeamObject>?
    
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
        mainStack.add(children: [(titleArea, 0.075), (UIView(), 0.025), (addTeamStack, 0.1), (UIView(), 0.025), (collectionView, nil), (UIView(), 0.05)])
        
        // Might as well set up the title area as long as we're at it
        titleArea.constrain(titleLabel, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "My Teams Title Label")
        
        addTeamStack.add(children: [(UIView(), 0.25), (addTeamButton, nil), (UIView(), 0.25)])
    }
    
    // 2
    private func setUpCollectionView() {
        collectionView.register(TeamCollectionCell.self, forCellWithReuseIdentifier: String(describing: TeamCollectionCell.self))
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
        
        print("TeamsView - setUpDataSource")
        
        dataSource = UICollectionViewDiffableDataSource<Section, TeamObject>(collectionView: collectionView) {
            (collectionView, indexPath, teamInformation) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: TeamCollectionCell.self),
                for: indexPath) as? TeamCollectionCell else {
                fatalError("Could not cast cell as \(TeamCollectionCell.self)")
            }
            cell.teamInformation = teamInformation
            cell.teamsViewDelegate = self
            return cell
        }
        
        collectionView.dataSource = dataSource
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, TeamObject>()
        snapshot.appendSections([.main])
        dataSource?.apply(snapshot)
    }
    
    // 4
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        titleArea.backgroundColor = Colors.titleAreaColor
        collectionView.backgroundColor = Colors.backgroundColor
        
        addTeamLabelView.backgroundColor = Colors.headerColor
        
        // Labels
        titleLabel.textColor = Colors.titleAreaTextColor
        
        // Buttons
        addTeamButton.backgroundColor = Colors.addButtonBackgroundColor
        addTeamButton.setTitleColor(Colors.addButtonTextColor, for: .normal)
        addTeamButton.layer.borderColor = Colors.addButtonBorderColor.cgColor
    }
}

// MARK: Actions

extension TeamsView {
    
    // The add button presents the search view
    @objc func presentTeamSearchViewController() {
        
        if let controller = viewController {
            let teamsViewController = TeamSearchViewController()
            teamsViewController.refreshableParent = self
            controller.present(teamsViewController, animated: true)
        }
    }
}

extension TeamsView: TeamsViewDelegate {
    
    func refresh(calledBy function: String) {
        
        print("TeamsView - Refreshing - called by \(function)")
        
        // 1. Retrieve all teams from cache. It must be async to deal with concurrency issues.
        var foundTeams = [TeamObject]()
        
        for team in QuickCache.helper.favoriteTeamsDictionary.sorted(by: { $0.value.name < $1.value.name }) {
            foundTeams.append(team.value)
        }
        
        guard let dataSource = dataSource else { return }
        
        // 2. Create a new snapshot using .main and append the teams that were found
        
        var snapShot = dataSource.snapshot(for: .main)
        
        snapShot.applyDifferences(newItems: foundTeams)
        
        // 3. Apply to datasource
        dataSource.apply(snapShot, to: .main, animatingDifferences: true)
    }
    
    func refresh(cell id: Int?) {
        if let teamId = id {
            for item in 0 ... collectionView.numberOfItems(inSection: 0) - 1 {
                let path = IndexPath(item: item, section: 0)
                guard let teamCell = collectionView.cellForItem(at: path) as? DEPRECATEDTeamCollectionCell else {
                    print("Could not cast \(path) as a teamcollectioncell")
                    continue }
                if teamCell.teamInformation?.id == teamId {
                    Task.init {
                        await teamCell.teamDataStack.manualRefresh()
                        print("ATTEMPTING TO REFRESH CELL")
                    }
                }
            }
        }
    }
    
    func add(team: TeamObject) {
        
        guard let dataSource = dataSource else { return }
        
        var snapshot = dataSource.snapshot(for: .main)
        
        let newItems = (snapshot.items + [team]).sorted(by: {$0.name < $1.name})
        
        snapshot.applyDifferences(newItems: newItems)
        
        dataSource.apply(snapshot, to: .main, animatingDifferences: true)
        
        
        Task.init {
            
            // 3. Add team to favorites. Once complete, update the Match section
            let team = try await DataFetcher.helper.addFavorite(team: team) {
                //self.refresh(calledBy: "TeamsView - Add - AddLeaguesFor - Completion Handler") }
            }
            try await DataFetcher.helper.addMatchesFor(team: team) {
                print("\n\n******\n******\n******\nCalling Completion For Matches\n******\n******\n******\n")
                self.refresh(cell: team.id)
            }
        }
    }
    
    func removeAnimation(completion: @escaping () -> ()) {
        
        // Create a blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurImageView = UIVisualEffectView(effect: blurEffect)
        blurImageView.clipsToBounds = true
        blurImageView.layer.cornerRadius = 25
        blurImageView.alpha = 0
        
        constrain(blurImageView, using: .scale, widthScale: 0.8, except: [.height], debugName: "BlurImageView Constrained To TeamSearchView")
        blurImageView.heightAnchor.constraint(equalTo: blurImageView.widthAnchor).isActive = true
        
        // Add a label to blur effect
        let addedTeamLabel = UILabel()
        addedTeamLabel.text = "Removed"
        addedTeamLabel.textColor = Colors.white.hexFFFCF9
        addedTeamLabel.alpha = 0
        addedTeamLabel.font = UIFont.systemFont(ofSize: 50)
        addedTeamLabel.adjustsFontSizeToFitWidth = true
        addedTeamLabel.numberOfLines = -1
        addedTeamLabel.textAlignment = .center
        blurImageView.contentView.constrain(addedTeamLabel, using: .scale, widthScale: 0.8, debugName: "Added Team Label Constrainted To BlurImageView")
        
        // Trigger feedback
        let feedback = UINotificationFeedbackGenerator()
        feedback.notificationOccurred(.success)
        
        // Animate
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear]) {
            blurImageView.alpha = 0.75
            addedTeamLabel.alpha = 1
        } completion: { (Bool) in
            UIView.animate(withDuration: 0.5, delay: 0.5, options: [.curveEaseInOut], animations: {
                blurImageView.alpha = 0
                addedTeamLabel.alpha = 0
            }, completion: { (Bool) in
                blurImageView.removeFromSuperview()
                addedTeamLabel.removeFromSuperview()
                completion()
                return
            })
            return
        }
    }
    
    func remove(team: TeamObject) {
        /// Called By removal button in Team Collection Cell
        Task.init {
            await Cached.data.favoriteTeamsRemoveValue(forKey: team.id)
            guard let dataSource = self.dataSource else { return }
            
            var snapShot = dataSource.snapshot(for: .main)
            snapShot.delete([team])
            await dataSource.apply(snapShot, to: .main, animatingDifferences: true)
        }
    }
    
    func present(_ viewController: UIViewController, completion:
                 (() -> Void)?) {
        self.viewController?.present(viewController, animated: true, completion: completion)
    }
}

// MARK: - Collection View Delegate

extension TeamsView: UICollectionViewDelegate {
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

extension UICollectionViewDiffableDataSource {
    /// Reapplies the current snapshot to the data source, animating the differences.
    /// - Parameters:
    ///   - completion: A closure to be called on completion of reapplying the snapshot.
    func refresh(completion: (() -> Void)? = nil) {
        self.apply(self.snapshot(), animatingDifferences: true, completion: completion)
    }
}
