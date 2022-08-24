//
//  LeagueSearchView.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit

class LeagueSearchView: UIView {
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var searchArea = UIStackView(.vertical)
    var searchLabelArea = UIView()
    
    var leagueSearchInputArea = UIView()
    var leagueSearchInputFieldView = UIView()
    var leagueSearchInputField = UITextField()
    
    var countrySearchInputArea = UIView()
    var countrySearchInputFieldView = UIView()
    var countrySearchInputField = UITextField()
    
    var collectionViewArea = UIView()
    var collectionView: UICollectionView!
    
    var spinner: UIActivityIndicatorView?
    
    // MARK: Buttons
    
    // MARK: Labels
    
    var searchLabel:  UILabel = {
        let label = UILabel()
        label.text = "Search for a league..."
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    } ()
    
    
    // MARK: Data
    var dataSource: UICollectionViewDiffableDataSource<Int, LeagueObject>!
    
    // MARK: Gestures
    
    // MARK: Constraints
    
    // MARK: Logic
    
    var viewController: LeagueSearchViewController?
    
    var currentLeagueNameSearch: String? = nil
    var currentCountrySearch: String? = nil
    
    var delegate: LeagueSearchDelegate?
    
    
    init() {
        super.init(frame: CGRect.zero)
        
        setUpMainStack()
        setUpSearchInputFields()
        setUpCollectionView()
        setUpColors()
        
        testing()
        
        leagueSearchInputField.delegate = self
        countrySearchInputField.delegate = self
        collectionView.delegate = self
    }
    
    func testing() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Set Up
    
    func setUpMainStack() {
        self.constrain(mainStack, safeAreaLayout: true)
        mainStack.add(children: [(UIView(), 0.05), (leagueSearchInputArea, 0.1), (countrySearchInputArea, 0.1), (collectionViewArea, nil), (UIView(), nil)])
    }
    
    func setUpSearchInputFields() {
        
        leagueSearchInputArea.constrain(leagueSearchInputFieldView, using: .scale, widthScale: 0.75, except: [.height], safeAreaLayout: true, debugName: "League Name Input Field View")
        leagueSearchInputFieldView.constrain(leagueSearchInputField, using: .edges, padding: 10, debugName: "League Name Input Field")
        leagueSearchInputFieldView.layer.borderWidth = 2
        leagueSearchInputFieldView.layer.cornerRadius = 5
        
        leagueSearchInputField.centerXAnchor.constraint(equalTo: leagueSearchInputArea.centerXAnchor).isActive = true
        leagueSearchInputField.backgroundColor = .clear
        leagueSearchInputField.returnKeyType = .search
        leagueSearchInputField.autocorrectionType = .no
        leagueSearchInputField.placeholder = "League Name"
        leagueSearchInputField.tag = 0
        
        countrySearchInputArea.constrain(countrySearchInputFieldView, using: .scale, widthScale: 0.75, except: [.height], safeAreaLayout: true, debugName: "Country Name Input Field View")
        countrySearchInputFieldView.constrain(countrySearchInputField, using: .edges, padding: 10, debugName: "Country Name Input Field")
        countrySearchInputFieldView.layer.borderWidth = 2
        countrySearchInputFieldView.layer.cornerRadius = 5
        
        countrySearchInputField.centerXAnchor.constraint(equalTo: countrySearchInputArea.centerXAnchor).isActive = true
        countrySearchInputField.backgroundColor = .clear
        countrySearchInputField.returnKeyType = .search
        countrySearchInputField.autocorrectionType = .no
        countrySearchInputField.placeholder = "Country"
        countrySearchInputField.tag = 1
    }
    
    func setUpCollectionView() {
        
        // MARK: Create list layout
        /*
         var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
         layoutConfig.showsSeparators = false
         layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
         layoutConfig.backgroundColor = Colors.backgroundColor
         let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
         */
        
        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: createCollectionViewLayout())
        collectionViewArea.constrain(collectionView, using: .edges, padding: 20)
        
        // MARK: Cell registration - What does the collectionview do to set up a cell - in this case simply passes data
        let cellRegistration = UICollectionView.CellRegistration<LeagueSearchCell, LeagueObject>(handler: {
            (cell, indexPath, leagueInformation) in
            
            cell.leagueInformation = leagueInformation
        })
        
        // MARK: Initialize data source - In order to initialize a datasource, you must pass a "Cell Provider" closure. This closure instructs the datasource what to do for each index
        dataSource = UICollectionViewDiffableDataSource<Int, LeagueObject>(collectionView: collectionView) {
            (collectionView, indexPath, leagueInformation) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: leagueInformation)
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, NSCollectionLayoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.2))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(
            sectionProvider: sectionProvider, configuration: config)
        
        return layout
    }
    
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        collectionView.backgroundColor = Colors.backgroundColor
        
        leagueSearchInputFieldView.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        
        leagueSearchInputField.textColor = Colors.searchResultViewTextColor
        
        countrySearchInputFieldView.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        
        countrySearchInputField.textColor = Colors.searchResultViewTextColor
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView(style: .large)
        self.constrain(spinner!, except: [.height])
        spinner!.heightAnchor.constraint(equalTo: spinner!.widthAnchor).isActive = true
        spinner!.startAnimating()
    }
    
    func removeSpinner() {
        guard let spinner = spinner else { return }
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    
    func returnSearchResults(teamResult: [LeagueObject]) {
        
        DispatchQueue.main.async {
            self.setUpDataSourceSnapshots(searchResult: teamResult)
        }
    }
    
    func setUpDataSourceSnapshots(searchResult: [LeagueObject]?) {
        // MARK: Setup snap shots
        
        guard let result = searchResult else { return }
        
        let leagues = result.map { $0 }//result.filter { !Saved.leagues.contains($0.league.id) }
        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<Int, LeagueObject>()
        snapshot.appendSections([0])
        snapshot.appendItems(leagues, toSection: 0)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    
    func addAnimation(completion: @escaping () -> ()) {
        
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
        addedTeamLabel.text = "Added!"
        addedTeamLabel.textColor = Colors.white.hexFFFCF9
        addedTeamLabel.alpha = 0
        addedTeamLabel.font = UIFont.systemFont(ofSize: 50)
        addedTeamLabel.adjustsFontSizeToFitWidth = true
        addedTeamLabel.numberOfLines = -1
        addedTeamLabel.textAlignment = .center
        blurImageView.contentView.constrain(addedTeamLabel, using: .scale, widthScale: 0.8, debugName: "Added League Label Constrainted To BlurImageView")
        
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
}

// Protocols

extension LeagueSearchView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField.tag == 0 {
            self.currentLeagueNameSearch = textField.text
        } else if textField.tag == 1 {
            self.currentCountrySearch = textField.text
        }
        
        searchForLeagues()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchForLeagues()
        
        textField.resignFirstResponder()
        
        return true
    }
    
    private func searchForLeagues() {
        
        Task.init {
            var searchResults = [LeagueObject]()
            
            for searchData in QuickCache.helper.leagueDictionary.values {
                if let country = currentCountrySearch, let league = currentLeagueNameSearch, league != "", country != "" {
                    if searchData.name.lowercased().contains(league.lowercased()), searchData.country.lowercased().contains(country.lowercased()) {
                        searchResults.append(searchData)
                    }
                } else if let country = currentCountrySearch, country != "" {
                    if searchData.country.lowercased().contains(country.lowercased()) {
                        searchResults.append(searchData)
                    }
                } else if let league = currentLeagueNameSearch, league != "" {
                    if searchData.name.lowercased().contains(league.lowercased()) {
                        searchResults.append(searchData)
                    }
                }
            }
            
            searchResults.sort { $0.id < $1.id }
            
            DispatchQueue.main.async {
                self.setUpDataSourceSnapshots(searchResult: searchResults)
            }
        }
    }
}

extension LeagueSearchView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? LeagueSearchCell, let league = cell.leagueInformation else { return }
        
        self.addAnimation() {
            self.viewController?.dismiss(animated: true)
            self.viewController?.delegate?.add(league: league)
        }
    }
}
