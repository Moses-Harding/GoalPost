//
//  Teams View.swift
//  GoalPost
//
//  Created by Moses Harding on 5/10/22.
//

import Foundation
import UIKit

class TeamsView: UIView {
    
    enum Section {
        case main
    }
    
    // MARK: Views
    
    // Collection View
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    // Stack View
    var mainStack = UIStackView(.vertical)
    var titleArea = UIStackView(.horizontal)
    var addTeamStack = UIStackView(.horizontal)
    
    // Other Views
    var collectionViewArea = UIView()
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

        self.refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods
    
    func createCollectionViewLayout() -> UICollectionViewLayout {
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
    
    private func setUpStacks() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(titleArea, 0.075), (UIView(), 0.05), (addTeamStack, 0.1), (collectionView, nil), (UIView(), 0.05)])
        
        // Might as well set up the title area as long as we're at it
        titleArea.constrain(titleLabel, using: .scale, widthScale: 0.5, heightScale: 1, padding: 5, except: [], safeAreaLayout: true, debugName: "My Teams Title Label")
        
        addTeamStack.add(children: [(UIView(), 0.25), (addTeamButton, 0.5), (UIView(), nil)])
    }
    
    private func setUpCollectionView() {
        collectionView.register(TeamCollectionCell.self, forCellWithReuseIdentifier: String(describing: TeamCollectionCell.self))
    }
    
    private func setUpDataSource() {
        
        var foundTeams = [TeamObject]()
        
        for team in Cached.favoriteTeams.sorted(by: { $0.value.name > $1.value.name} ) {
            foundTeams.append(team.value)
        }
        
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
        snapshot.appendItems(foundTeams)
        dataSource?.apply(snapshot)
    }
    
    func applyTeamsToDataSourceSnapshot(_ teamObjects: [TeamObject]?) {
        // MARK: Setup snap shots

        guard let result = teamObjects, let dataSource = dataSource else { return }
        
        let teams = result.map { $0 }

        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<Section, TeamObject>()
        snapshot.appendSections([.main])
        snapshot.appendItems(teams, toSection: .main)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func addTeamToDataSource(team: TeamObject) {
        guard let dataSource = dataSource else { return }
        
        var snapshot = dataSource.snapshot(for: .main)
        snapshot.append([team])
        dataSource.apply(snapshot, to: .main)
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

// MARK: Actions

extension TeamsView {
    @objc func presentTeamSearchViewController() {
        
        if let controller = viewController {
            let teamsViewController = TeamSearchViewController()
            teamsViewController.refreshableParent = self
            controller.present(teamsViewController, animated: true)
        }
    }
}

extension TeamsView: TeamsViewDelegate {
    
    // Refresh
    func refresh() {
        
        print("TeamsView - Refreshing")
        
        var foundTeams = [TeamObject]()
        
        for team in Cached.favoriteTeams {
            foundTeams.append(team.value)
        }
        
        applyTeamsToDataSourceSnapshot(foundTeams)
    }
    
    func add(team: TeamObject) {
        
        addTeamToDataSource(team: team)
        
        var capturedCell: TeamCollectionCell?
        
        for eachCell in collectionView.visibleCells {
            guard let teamCell = eachCell as? TeamCollectionCell else { continue }
            if teamCell.teamInformation?.id == team.id {
                capturedCell = teamCell
            }
        }
        
        guard let cell = capturedCell else { fatalError("TeamsView - Could not locate cell to update") }
        
        cell.teamDataStack.load(.match)
        cell.teamDataStack.load(.transfer)
        cell.teamDataStack.load(.injury)
        
        Task.init {
            let team = try await DataFetcher.helper.addLeaguesFor(team: team)
                try await DataFetcher.helper.addMatchesFor(team: team) {
                    print("\n\n******\n******\n******\nCalling Completion For Matches\n******\n******\n******\n")
                    cell.teamDataStack.matchLoading = false
                    cell.teamDataStack.updateMatchSection()
                }
                try await DataFetcher.helper.addTransfersFor(team: team) {
                    print("\n\n******\n******\n******\nCalling Completion For Transfer\n******\n******\n******\n")
                    cell.teamDataStack.transferLoading = false
                    cell.teamDataStack.updateTransferSection() }
                try await DataFetcher.helper.addInjuriesFor(team: team) {
                    print("\n\n******\n******\n******\nCalling Completion For Injury\n******\n******\n******\n")
                    cell.teamDataStack.injuryLoading = false
                    cell.teamDataStack.updateInjurySection() }
        }
        
        cell.isSelected = true
    }
    
    func remove(team: TeamObject) {
        Cached.favoriteTeams.removeValue(forKey: team.id)
        self.refresh()
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
