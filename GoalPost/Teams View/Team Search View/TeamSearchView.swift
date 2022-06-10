//
//  TeamsSearchView.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit

class TeamSearchView: UIView {
    
    // MARK: Views
    
    var mainStack = UIStackView(.vertical)
    
    var searchArea = UIStackView(.vertical)
    var searchLabelArea = UIView()
    
    var teamSearchInputArea = UIView()
    var teamSearchInputFieldView = UIView()
    var teamSearchInputField = UITextField()
    
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
        label.text = "Search for a team..."
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    } ()

    
    // MARK: Data
    var dataSource: UICollectionViewDiffableDataSource<Int, TeamObject>!
    
    // MARK: Gestures
    
    
    // MARK: Constraints
    
    // MARK: Logic
    
    var viewController: TeamSearchViewController?
    
    var currentTeamNameSearch: String? = nil
    var currentCountrySearch: String? = nil

    
    init() {
        super.init(frame: CGRect.zero)
        
        setUpMainStack()
        setUpSearchInputFields()
        setUpCollectionView()
        setUpColors()
        
        testing()
        
        //GetTeams.helper.delegate = self
        teamSearchInputField.delegate = self
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
        mainStack.add(children: [(UIView(), 0.05), (teamSearchInputArea, 0.1), (countrySearchInputArea, 0.1), (collectionViewArea, nil), (UIView(), nil)])
    }
    
    func setUpSearchInputFields() {
        
        teamSearchInputArea.constrain(teamSearchInputFieldView, using: .scale, widthScale: 0.75, except: [.height], safeAreaLayout: true, debugName: "Team Name Input Field View")
        teamSearchInputFieldView.constrain(teamSearchInputField, using: .edges, padding: 10, debugName: "Team Name Input Field")
        teamSearchInputFieldView.layer.borderWidth = 2
        teamSearchInputFieldView.layer.cornerRadius = 5
        
        teamSearchInputField.centerXAnchor.constraint(equalTo: teamSearchInputArea.centerXAnchor).isActive = true
        teamSearchInputField.backgroundColor = .clear
        teamSearchInputField.returnKeyType = .search
        teamSearchInputField.autocorrectionType = .no
        teamSearchInputField.placeholder = "Team Name"
        teamSearchInputField.tag = 0
        
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
        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        layoutConfig.showsSeparators = false
        layoutConfig.separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .grouped)
        layoutConfig.backgroundColor = Colors.backgroundColor
        let listLayout = UICollectionViewCompositionalLayout.list(using: layoutConfig)

        // MARK: Configure Collection View
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: listLayout)
        collectionViewArea.constrain(collectionView, using: .edges, padding: 20)
        
        // MARK: Cell registration - What does the collectionview do to set up a cell - in this case simply passes data
        let cellRegistration = UICollectionView.CellRegistration<TeamSearchCell, TeamObject>(handler: {
            (cell, indexPath, teamInformation) in
            
            cell.teamInformation = teamInformation
        })
            
        // MARK: Initialize data source - In order to initialize a datasource, you must pass a "Cell Provider" closure. This closure instructs the datasource what to do for each index
        dataSource = UICollectionViewDiffableDataSource<Int, TeamObject>(collectionView: collectionView) {
            (collectionView, indexPath, teamInformation) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: teamInformation)
        }
    }
    
    func setUpDataSourceSnapshots(searchResult: [TeamObject]?) {
        // MARK: Setup snap shots
        
        
        guard let result = searchResult else { return }
        
        let teams = result.map { $0 }//result.filter { !Saved.leagues.contains($0.team.id) }

        
        // Create a snapshot that define the current state of data source's data
        var snapshot = NSDiffableDataSourceSnapshot<Int, TeamObject>()
        snapshot.appendSections([0])
        snapshot.appendItems(teams, toSection: 0)
        
        // Display data on the collection view by applying the snapshot to data source
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func setUpColors() {
        // Views
        mainStack.backgroundColor = Colors.backgroundColor
        collectionView.backgroundColor = Colors.backgroundColor
        
        teamSearchInputFieldView.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        
        teamSearchInputField.textColor = Colors.searchResultViewTextColor
        
        countrySearchInputFieldView.layer.borderColor = Colors.searchResultViewBorderColor.cgColor
        
        countrySearchInputField.textColor = Colors.searchResultViewTextColor
    }
    
    // MARK: Retrieving search result
    
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
    
    
    func returnSearchResults(teamResult: [TeamObject]) {

        DispatchQueue.main.async {
            self.setUpDataSourceSnapshots(searchResult: teamResult)
        }
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
}

// Protocols

extension TeamSearchView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField.tag == 0 {
            self.currentTeamNameSearch = textField.text
        } else if textField.tag == 1 {
            self.currentCountrySearch = textField.text
        }
        
        searchForTeams()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let text = textField.text, let teamName = self.currentTeamNameSearch else { return false }
        
        self.addSpinner()
        
        Task.init {
            // Note - Country search is optional
            let teamDictionary: [TeamID:TeamObject] = try await GetTeams.helper.search(for: teamName, countryName: self.currentCountrySearch)
            let resultList = teamDictionary.values.map { $0 }.sorted { $0.id < $1.id }
            self.returnSearchResults(teamResult: resultList)
            Cached.teamDictionary.integrate(teamDictionary, replaceExistingValue: false)
            self.removeSpinner()
        }
        textField.resignFirstResponder()
        
        return true
    }
    
    private func searchForTeams() {
        
        var searchResults = [TeamObject]()
        
        for searchData in Cached.teamDictionary.values {
            if let country = currentCountrySearch, let team = currentTeamNameSearch {
                if searchData.name.lowercased().contains(team.lowercased()) && searchData.country != nil && searchData.country!.lowercased().contains(country.lowercased()) {
                    searchResults.append(searchData)
                }
            } else if let country = currentCountrySearch {
                if searchData.country != nil && searchData.country!.lowercased().contains(country.lowercased()) {
                    searchResults.append(searchData)
                }
            } else if let team = currentTeamNameSearch {
                if searchData.name.lowercased().contains(team.lowercased()) {
                    searchResults.append(searchData)
                }
            }
        }
        
        searchResults.sort { $0.id < $1.id }
        
        self.returnSearchResults(teamResult: searchResults)
    }
}


extension TeamSearchView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TeamSearchCell, let team = cell.teamInformation else { return }
        
        self.addAnimation() {
            self.viewController?.dismiss(animated: true)
            self.viewController?.refreshableParent?.refresh()
            self.viewController?.refreshableParent?.add(team: team)
        }
    }
}
