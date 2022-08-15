//
//  MatchesView 2.0.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit

class MatchesView: UIView, UIGestureRecognizerDelegate {
    
    // MARK: Views
    
    var mainStack = CustomStack(.vertical)
    
    var dateArea = UIStackView(.horizontal)
    var collectionArea = UIView()
    var buttonArea = UIView()
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    // MARK: Buttons
    
    var nextDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        return button
    } ()
    
    var previousDayButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(previousDay), for: .touchUpInside)
        return button
    } ()
    
    // MARK: Labels
    
    var dateLabel = UILabel()
    
    // MARK: Data
    
    var currentDate = Date()
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ObjectContainer>!
    
    // MARK: Gestures
    
    var swipeLeft = UISwipeGestureRecognizer()
    var swipeRight = UISwipeGestureRecognizer()
    var refreshControl: UIRefreshControl!
    
    init() {
        super.init(frame: CGRect.zero)
        
        setUpUI()
        setUpCollectionView()
        setUpDataSource()
        setUpColors()
        setUpGestures()
        applyData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    // 1
    func setUpUI() {
        print("Set up ui")
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(dateArea, 0.075), (collectionArea, 0.9)])
        collectionArea.constrain(collectionView)
        
        // Date
        dateLabel.text = DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none)
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textAlignment = .center
        dateArea.add(children: [(previousDayButton, 0.2), (dateLabel, 0.6), (nextDayButton, nil)])
    }
    
    // 2
    private func setUpCollectionView() {
        print("set up collectionview")
        collectionView.register(MatchesContainerCell.self, forCellWithReuseIdentifier: String(describing: MatchesContainerCell.self))
    }
    
    // 2.5 - Called via lazy initialization of collectionview
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        print("Initializing collectionview layout")
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
        
        print("MatchesView - setUpDataSource")
        Task.init {
            dataSource = UICollectionViewDiffableDataSource<Section, ObjectContainer>(collectionView: collectionView) {
                (collectionView, indexPath, objectContainer) -> UICollectionViewCell? in
                
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: String(describing: MatchesContainerCell.self),
                    for: indexPath) as? MatchesContainerCell else {
                    fatalError("Could not cast cell as \(MatchesContainerCell.self)")
                }
                
                cell.objectContainer = objectContainer
                
                return cell
            }
            
            collectionView.dataSource = dataSource
            
            var snapshot = NSDiffableDataSourceSnapshot<Section, ObjectContainer>()
            
            snapshot.appendSections([.main])
            //snapshot.appendItems(foundTeams)
            await dataSource?.apply(snapshot)
        }
    }
    
    // 4
    // NOTE: CollectionView backgroundColor is set up by changing the layout color in setUpCollectionView
    func setUpColors() {
        
        // Buttons
        nextDayButton.tintColor = Colors.titleAreaTextColor
        previousDayButton.tintColor = Colors.titleAreaTextColor
        
        // Labels
        dateLabel.textColor = Colors.titleAreaTextColor
        
        // Backgrounds
        dateArea.backgroundColor = Colors.titleAreaColor
        
        collectionArea.backgroundColor = .yellow
    }
    
    // 5
    func setUpGestures() {
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(nextDay))
        addGestureRecognizer(swipeLeft)
        swipeLeft.delegate = self
        swipeLeft.direction = .left
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(previousDay))
        addGestureRecognizer(swipeRight)
        swipeRight.delegate = self
        swipeRight.direction = .right
    }
    
    func applyData() {
        Task.init {
            var leagues = [ObjectContainer]()
            leagues.append(ObjectContainer(favoriteLeague: true))
            let favoriteLeagues = await Cached.data.favoriteLeagues
            for leagueID in favoriteLeagues.keys {
                leagues.append(ObjectContainer(leagueId: leagueID))
                
                guard let dataSource = dataSource else { return }
                
                var snapShot = dataSource.snapshot(for: .main)
                snapShot.deleteAll()
                snapShot.append(leagues)
                
                // 3. Apply to datasource
                await dataSource.apply(snapShot, to: .main, animatingDifferences: true)
            }
        }
    }
}

extension MatchesView {
    @objc func nextDay() {
        print("next day")
    }
    
    @objc func previousDay() {
        print("previous day")
    }
    
    func refresh() {
        print("refresh")
    }
}
