//
//  MatchesViewCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//

import Foundation
import UIKit


class MatchesContainerCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    //var leagueInformation: LeagueObject? { didSet { updateContent() } }
    var objectContainer: ObjectContainer? { didSet { updateContent() } }
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    
    // Views
    let logoArea = UIView()
    let nameArea = UIView()
    
    // Labels
    let nameLabel = UILabel()
    
    let leagueLogo = UIImageView()
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    
    var titleStack = UIStackView(.horizontal)
    
    var bodyStack = UIStackView(.vertical)
    var matchesContainerBodyStack: MatchesContainerBodyStack!
    
    var closedConstraint: NSLayoutConstraint?
    var openConstraint: NSLayoutConstraint?
    
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
        let padding: CGFloat = 5
        contentView.constrain(mainStack, using: .edges, padding: padding, except: [.bottom], debugName: "Main Stack to Content View - Team Collection Cell")
        mainStack.add([titleStack, bodyStack])
        
        closedConstraint =
        titleStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        closedConstraint?.priority = .defaultLow // use low priority so stack stays pinned to top of cell
        
        openConstraint =
        bodyStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: padding)
        openConstraint?.priority = .defaultLow
        
        closedConstraint?.isActive = true
    }
    
    // 2
    func setUpTitleStack() {
        titleStack.add(children: [(UIView(), 0.05), (nameArea, 0.8), (UIView(), nil), (logoArea, nil), (UIView(), 0.05)])
        titleStack.alignment = .center
        
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - Team Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        logoArea.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoArea.constrain(leagueLogo, except: [.height, .width], debugName: "TeamLogo to Logo Area - Team Collection Cell")
        leagueLogo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        leagueLogo.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    // 3
    func setUpBodyStack() {
        
        matchesContainerBodyStack = MatchesContainerBodyStack(objectContainer: objectContainer)

        bodyStack.add(children: [(UIView(), 0.05), (matchesContainerBodyStack, nil), (UIView(), 0.05)])
        bodyStack.isHidden = true
    }
    
    // 4
    func setUpColors() {
        self.backgroundColor = Colors.teamCellViewBackgroundColor
        nameLabel.textColor = .white
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        
        print("Cell selected")
    }
    
    func updateContent() {
        
        Task.init {
            guard let objectContainer = objectContainer else { return }
            
            if let league = await objectContainer.league() {
            nameLabel.text = league.name
            await loadImage(for: league)
            }
            
            if objectContainer.favoriteLeague {
                nameLabel.text = "My Teams"
            }
        }
    }
    
    func loadImage(for league: LeagueObject) async {
        
        let imageName = "\(league.name) - \(league.id).png"
        
        
        if let image = await Cached.data.retrieveImage(from: imageName) {
            
            self.leagueLogo.image = image
            
            return
        }
        
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
    
    override func prepareForReuse() {
        //
    }
}
