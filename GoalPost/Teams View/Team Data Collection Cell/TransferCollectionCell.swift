//
//  TransferCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 5/31/22.
//

import Foundation
import UIKit

class TransferCollectionCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    var teamDataObject: TeamDataObject? { didSet { updateContent() } }
    
    // MARK: - Private Properties
    
    // Views
    let playerNameArea = UIView()
    let playerImageArea = UIView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let transferFromTeam = UILabel()
    let transferToTeam = UILabel()
    let transferDate = UILabel()
    
    // Image
    let playerImage = UIImageView()
    
    // Stacks
    var mainStack = UIStackView(.vertical)
    
    //var titleStack = UIStackView(.vertical)
    var bodyStack = UIStackView(.horizontal)
    var descriptionStack = UIStackView(.vertical)

    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    // MARK: - Private Methods
    
    func setUp() {
        layer.cornerRadius = 15

        setUpStacks()
        setUpViewContent()
        setUpColors()

    }
    
    func setUpStacks() {
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - TransferCollectionCell")
        mainStack.add(children: [(UIView(), 0.05), (transferDate, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05),])
        bodyStack.add(children: [(UIView(), 0.025), (playerImageArea, nil), (UIView(), 0.1), (descriptionStack, nil), (UIView(), nil)])
        
        descriptionStack.add(children: [(UIView(), 0.025), (playerNameArea, nil), (UIView(), 0.1), (transferFromTeam, nil), (UIView(), 0.1), (transferToTeam, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {

        // Image
        playerImageArea.constrain(playerImage, except: [.height], debugName: "PlayerImage To PlayerImageArea - TransferCollectionCell")
        playerImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        playerImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        playerImage.layer.cornerRadius = 10
        playerImage.clipsToBounds = true
        
        // Labels
        transferDate.font = UIFont.preferredFont(forTextStyle: .title2)//UIFont.boldSystemFont(ofSize: 30)
        transferDate.numberOfLines = -1
        transferDate.textAlignment = .center
        
        playerNameArea.constrain(playerNameLabel, debugName: "PlayerNameLabel To PlayerNameArea - TransferCollectionCell")
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        playerNameLabel.textAlignment = .left
        
        transferToTeam.numberOfLines = -1

    }

    func updateContent() {
        guard let transferInfo = teamDataObject?.transfer else { return }

        transferFromTeam.text = "From: \(String(describing: transferInfo.teamFrom?.name))"
        transferToTeam.text = "To: \(String(describing: transferInfo.teamTo?.name))"
        transferDate.text = transferInfo.transferDate.formatted(date: .numeric, time: .omitted)
        
        if let player = transferInfo.player {
            playerNameLabel.text = player.name
            loadImage(for: player)
        }
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        greenLine.backgroundColor = Colors.logoTheme
    }
    
    func loadImage(for player: PlayerObject) {
        
        let imageName = "\(player.name) - \(player.id).png"
        
        if let image = Cached.data.retrieveImage(from: imageName) {
            
            self.playerImage.image = image
            
            return
        }
        
        guard let photo = player.photo, let url = URL(string: photo) else { return }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.playerImage.image = image
                    
                    Cached.data.save(image: image, uniqueName: imageName)
                }
            }
        }
    }
}
