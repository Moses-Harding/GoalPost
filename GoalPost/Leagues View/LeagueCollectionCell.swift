//
//  LeaguesCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/16/22.
//

import Foundation
import UIKit

class LeagueCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var leagueInformation: LeagueObject? { didSet { updateContent() } }
    var leaguesViewDelegate: LeaguesViewDelegate?
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    // MARK: - Private Properties
    
    // Views
    let logoArea = UIView()
    let nameArea = UIView()
    
    // Labels
    let nameLabel = UILabel()
    let foundedLabel = UILabel()
    let countryLabel = UILabel()
    let codeLabel = UILabel()
    let nationalLabel = UILabel()
    
    // Image
    let leagueLogo = UIImageView()
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    
    var titleStack = UIStackView(.horizontal)
    
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
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        let padding: CGFloat = 5
        contentView.constrain(mainStack, using: .edges, padding: padding, debugName: "Main Stack to Content View - League Collection Cell")
        mainStack.add([titleStack])
    }
    
    // 2
    func setUpTitleStack() {
        titleStack.add(children: [(UIView(), 0.05), (nameArea, 0.8), (UIView(), nil), (logoArea, nil), (UIView(), 0.05)])
        titleStack.alignment = .center
        
        nameArea.constrain(nameLabel, using: .edges, widthScale: 0.8, debugName: "Name label to name area - League Collection Cell")
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        
        logoArea.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoArea.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        logoArea.constrain(leagueLogo, except: [.height, .width], debugName: "LeagueLogo to Logo Area - League Collection Cell")
        leagueLogo.heightAnchor.constraint(equalToConstant: 25).isActive = true
        leagueLogo.widthAnchor.constraint(equalToConstant: 25).isActive = true
    }

    
    // 4
    func setUpColors() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = Colors.teamDataStackCellTextColor.cgColor
        self.layer.borderWidth = 1
        nameLabel.textColor = Colors.teamDataStackCellTextColor
    }
    
    // MARK: Externally Triggered
    
    func updateAppearance() {
        
        if isSelected {
            let viewController = LeagueDataViewController()
            leaguesViewDelegate?.present(viewController) {
                viewController.leagueDataView.league = self.leagueInformation
                viewController.leaguesViewDelegate = self.leaguesViewDelegate
            }
        } else {
            print("Not selected")
        }
    }
    
    func updateContent() {
        
        guard let leagueInfo = leagueInformation else { return }
        Task.init {
            nameLabel.text = leagueInfo.name
            await loadImage(for: leagueInfo)
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

    }
}

