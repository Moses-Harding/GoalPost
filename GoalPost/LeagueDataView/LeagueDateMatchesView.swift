//
//  LeagueDateMatchesView.swift
//  GoalPost
//
//  Created by Moses Harding on 10/25/22.
//

import Foundation
import UIKit

class LeagueDateMatchesView: UIView {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, ObjectContainer>?
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    
    let mainView = UIView()
    let backgroundStackView = UIStackView(.vertical)
    let collectionViewArea = UIView()
    let dateStack = UIStackView(.horizontal)
    
    let removalButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    } ()
    
    let dateLabel = UILabel()
    
    var leagueDateObject: LeagueDateObject? { didSet { updateData() } }
    var viewController: UIViewController?
    
    init() {
        super.init(frame: .zero)
        
        setUpMainStack()
        setUpCollectionView()
        setUpColors()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpColors() {
        self.backgroundColor = .clear
        
        collectionView.backgroundColor = .clear
        backgroundStackView.backgroundColor = .black
        
        dateLabel.font = UIFont.boldSystemFont(ofSize: 24)
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true

    }
    
    func setUpMainStack() {
        // Set Up Structure
        
        self.constrain(mainView, using: .scale, widthScale: 0.95, heightScale: 1)
        
        mainView.isUserInteractionEnabled = true
        
        let touchStack = UIView()
        mainView.constrain(touchStack)
        touchStack.recognizeTaps(tapNumber: 1, target: self, action: #selector(close))
        
        mainView.constrain(backgroundStackView, using: .scale, heightScale: 0.8)
        
        let buttonStack = UIStackView(.vertical)
        buttonStack.distribution = .equalCentering
        buttonStack.add([UIView(), removalButton, UIView()])
        removalButton.widthAnchor.constraint(equalTo: removalButton.heightAnchor).isActive = true
        
        dateStack.add(children: [(UIView(), 0.1), (buttonStack, 0.1), (dateLabel, nil), (UIView(), 0.1)])
        
        backgroundStackView.add(children: [(UIView(), 0.025), (dateStack, 0.15), (collectionViewArea, nil), (UIView(), 0.05)])
        backgroundStackView.layer.cornerRadius = 25
        
        collectionViewArea.constrain(collectionView, using: .scale, widthScale: 0.9, debugName: "collectionView to collectionViewArea - LeagueDateMatchesView")
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 50
        self.insertSubview(blurView, at: 0)
        
        NSLayoutConstraint.activate([
          blurView.topAnchor.constraint(equalTo: self.topAnchor),
          blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
          blurView.heightAnchor.constraint(equalTo: self.heightAnchor),
          blurView.widthAnchor.constraint(equalTo: self.widthAnchor)
        ])
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        
        // The item and group will share this size to allow for automatic sizing of the cell's height
        
        let padding: CGFloat = 0
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(90))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 5, leading: padding, bottom: 0, trailing: padding)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func setUpCollectionView() {
        collectionView.register(MatchCell.self, forCellWithReuseIdentifier: String(describing: MatchCell.self))
        
        dataSource = UICollectionViewDiffableDataSource<Section, ObjectContainer>(collectionView: collectionView) {
            (collectionView, indexPath, objectContainer) -> UICollectionViewCell? in
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String(describing: MatchCell.self),
                for: indexPath) as? MatchCell else {
                fatalError("Could not cast cell as \(MatchCell.self)") }
            
            cell.objectContainer = objectContainer
            return cell

        }
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ObjectContainer>()
        snapshot.appendSections([.main])
        dataSource?.apply(snapshot)
    }
    
    func updateData() {

        guard let dataSource = self.dataSource, let leagueDateObject = self.leagueDateObject else { return }
        
        let matches = leagueDateObject.matchIds.map { ObjectContainer(matchId: $0) }
        
        var snapShot = dataSource.snapshot(for: .main)
        snapShot.applyDifferences(newItems: matches)

        dataSource.apply(snapShot, to: .main, animatingDifferences: true)
        
        dateLabel.text = leagueDateObject.dateString
    }
}

extension LeagueDateMatchesView {
    @objc func close() {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

extension LeagueDateMatchesView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let viewController = self.viewController, let cell = collectionView.cellForItem(at: indexPath) as? MatchCell, let match = cell.objectContainer, let id = match.matchId, let selectedMatch = QuickCache.helper.matchesDictionary[id] else { return }

        let matchDataViewController = MatchDataViewController()
        matchDataViewController.matchDataView.match = selectedMatch
        viewController.present(matchDataViewController, animated: true)
    }
}
