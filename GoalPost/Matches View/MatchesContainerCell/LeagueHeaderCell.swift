//
//  MatchesViewCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit


class LeagueHeaderCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    //var leagueInformation: LeagueObject? { didSet { updateContent() } }
    var objectContainer: ObjectContainer? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    
    // Views
    let logoArea = UIView()
    let countryImageArea = UIView()
    let nameArea = UIView()
    
    // Labels
    let nameLabel = UILabel()
    
    let countryImage = UIImageView()
    let leagueLogo = UIImageView()
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    
    var titleStack = UIStackView(.horizontal)
    
    var bodyStack = UIStackView(.vertical)
    var matchesContainerBodyStack: MatchesContainerBodyStack!
    
    var cellHeightConstraint: NSLayoutConstraint?
    var logoWidthConstraint: NSLayoutConstraint?
    var logoHeightConstraint: NSLayoutConstraint?
    var countryWidthConstraint: NSLayoutConstraint?
    var countryHeightConstraint: NSLayoutConstraint?

    // Data
    
    var hasCountryLogo = false
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUp()
    }
    
    // MARK: - Set Up
    
    func setUp() {
        
        layer.cornerRadius = 8
        
        setUpMainStack()
        setUpTitleStack()
        setUpBodyStack()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        
        addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutMarginsGuide = layoutMarginsGuide
        
        let leadingMain = mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor)
        let trailingMain = mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor)
        let topMain = mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15)
        let bottomMain = mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        NSLayoutConstraint.activate([ leadingMain, trailingMain, topMain, bottomMain ])
        
        mainStack.add([titleStack])
    }
    
    // 2
    func setUpTitleStack() {

        titleStack.add(children: [(UIView(), 0.05), (countryImageArea, nil), (UIView(), 0.05), (nameArea, 0.7), (UIView(), nil), (logoArea, nil), (UIView(), 0.05)])
        titleStack.alignment = .center
        
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - Team Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.numberOfLines = -1
        nameLabel.textAlignment = .center
        
        logoArea.constrain(leagueLogo, except: [.height], debugName: "League Logo to Logo Area - League Header Cell")
        countryImageArea.constrain(countryImage, except: [.height], debugName: "Country Image to Country Image Area - League Header Cell")
    }
    
    // 3
    func setUpBodyStack() {
        
        matchesContainerBodyStack = MatchesContainerBodyStack(objectContainer: objectContainer)
        
        bodyStack.add(children: [(UIView(), 0.05), (matchesContainerBodyStack, nil), (UIView(), 0.05)])
        bodyStack.isHidden = true
    }
    
    // 4
    func setUpColors() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = Colors.cellTextGreen.cgColor
        self.layer.borderWidth = 1
        nameLabel.textColor = Colors.cellTextGreen
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        if isSelected {
            self.backgroundColor = Colors.cellBackgroundGray
            nameLabel.textColor = .white
        } else {
            self.backgroundColor = UIColor.clear
            nameLabel.textColor = Colors.cellTextGreen
        }
    }
    
    func updateContent() {
        
        Task.init {
            guard let objectContainer = objectContainer else { return }
            
            if let league = objectContainer.league {
                nameLabel.text = league.name
                loadImage(for: league)
            }
            
            if objectContainer.favoriteLeague {
                nameLabel.text = "My Teams"
                leagueLogo.image = nil
            }
            
            if let logoWidth = logoWidthConstraint{ logoWidth.isActive = false }
            if let logoHeight = logoHeightConstraint { logoHeight.isActive = false }
            if let countryWidth = countryWidthConstraint{ countryWidth.isActive = false }
            if let countryHeight = countryHeightConstraint { countryHeight.isActive = false }
            
            cellHeightConstraint?.isActive = true
            logoHeightConstraint = leagueLogo.widthAnchor.constraint(equalToConstant: 30)
            logoHeightConstraint?.isActive = true
            logoWidthConstraint = leagueLogo.heightAnchor.constraint(equalToConstant: leagueLogo.image?.resize(.height, proportionalTo: 30).height ?? 30)
            logoWidthConstraint?.isActive = true

            if objectContainer.favoriteLeague || !hasCountryLogo {
                countryImage.image = UIImage(named: "GoalPostIcon - Transparent")
                countryHeightConstraint = countryImage.widthAnchor.constraint(equalToConstant: 30)
                countryHeightConstraint?.isActive = true
                countryWidthConstraint = countryImage.heightAnchor.constraint(equalToConstant: 30)
                countryWidthConstraint?.isActive = true
            } else {
                countryHeightConstraint = countryImage.widthAnchor.constraint(equalToConstant: 30)
                countryHeightConstraint?.isActive = true
                countryWidthConstraint = countryImage.heightAnchor.constraint(equalToConstant: 20)
                countryWidthConstraint?.isActive = true
            }
            
            countryImage.layer.cornerRadius = 4
            countryImage.clipsToBounds = true
        }
    }
    
    func loadImage(for league: LeagueObject) {
        
        let imageName = "\(league.name) - \(league.id).png"
        
        if let image = QuickCache.helper.retrieveImage(from: imageName) {
            self.leagueLogo.image = image
        } else {
            guard let url = URL(string: league.logo!) else { return }
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        
                        guard let image = UIImage(data: data) else { return }
                        
                        self.leagueLogo.image = image
                        
                        Task.init {
                            await Cached.data.save(image: image, uniqueName: imageName)
                        }
                    }
                }
            }
        }
        
        guard let countryLogoURL = league.countryLogo else {
            print("LeagueHeaderCell - LoadImage - No logo for \(league)")
            hasCountryLogo = false
            return
        }
        
        hasCountryLogo = true

        if let image = UIImage(named: countryLogoURL) {
            
            self.countryImage.image = image
            return
        } else {
            print("LeagueHeaderCell - loadImage - No country logo retrieved for \(league.name)")
        }
    }
    
    override func prepareForReuse() {

    }
}
