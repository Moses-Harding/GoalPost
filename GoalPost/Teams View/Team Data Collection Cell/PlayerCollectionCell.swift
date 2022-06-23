//
//  PlayerCollectionCell.swift
//  GoalPost
//
//  Created by Moses Harding on 6/13/22.
//

import Foundation
import UIKit

class PlayerCollectionCell: TeamDataStackCellModel {
    
    // Views
    
    var playerImageArea = UIView()
    var playerImage = UIImageView()
    let greenLine = UIView()
    
    // Labels
    let playerNameLabel = UILabel()
    let playerPositionLabel = UILabel()
    let playerNumberLabel = UILabel()
    let playerAgeLabel = UILabel()
    
    var allLabels: [UILabel] {
        return [playerNameLabel, playerPositionLabel, playerNumberLabel, playerAgeLabel]
    }
    
    // Stacks
    
    var bodyStack = UIStackView(.horizontal)
    let playerDetailStack = UIStackView(.vertical)
    
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
        
        setUpStacks()
        setUpViewContent()
        setUpColors()
        
    }
    
    func setUpStacks() {
        
        contentStack.add(children: [(UIView(), 0.05), (playerNameLabel, 0.2), (UIView(), 0.05), (greenLine, 0.02), (UIView(), 0.05), (bodyStack, nil), (UIView(), 0.05)])
        bodyStack.add(children: [(UIView(), 0.05), (playerImageArea, 0.4), (UIView(), 0.05), (playerDetailStack, nil), (UIView(), 0.05)])
        playerDetailStack.add(children: [(UIView(), 0.05), (playerPositionLabel, nil), (UIView(), 0.025), (playerNumberLabel, nil), (UIView(), nil)])
    }
    
    func setUpViewContent() {
        
        playerImageArea.constrain(playerImage, using: .scale, widthScale: 1, heightScale: 1, padding: 1, except: [.height], safeAreaLayout: false, debugName: "Player Image -> Player Image Area")
        
        playerNameLabel.textAlignment = .center
        playerNumberLabel.textAlignment = .center
        playerPositionLabel.textAlignment = .center
        
        playerNameLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        playerNameLabel.numberOfLines = -1
        
        playerImage.layer.cornerRadius = 10
        playerImage.clipsToBounds = true
        playerImage.heightAnchor.constraint(equalTo: playerImage.widthAnchor).isActive = true
    }
    
    override func updateContent() {
        
        Task.init {
            
            guard let teamDataObject = teamDataObject else {
                print("no team data object found")
                return }
            guard let player = await teamDataObject.player() else {
                print("No player found for team data object \(teamDataObject.id) - id \(teamDataObject.playerID)")
                return }
            
            playerNameLabel.text = "\(player.name)"
            playerNumberLabel.text = "#\(String(player.number))"
            playerPositionLabel.text = player.position
            
            loadImage(for: player)
        }
    }
    
    func setUpColors() {
        self.backgroundColor = Colors.teamDataStackCellBackgroundColor
        allLabels.forEach { $0.textColor = Colors.teamDataStackCellTextColor }
        greenLine.backgroundColor = Colors.teamDataStackCellTextColor
    }
    
    private func loadImage(for player: PlayerObject) {
        
        let imageName = "Player - \(player.id).png"
        
        Task.init {
            if let image = await Cached.data.retrieveImage(from: imageName) {
                
                self.playerImage.image = image
                
                return
            }
        }
        
        guard let photo = player.photo, let url = URL(string: photo)  else { return }
        
        //let url = URL(string: team.logo)!
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    
                    guard let image = UIImage(data: data) else { return }
                    
                    self.playerImage.image = image
                    
                    Task.init {
                        await Cached.data.save(image: image, uniqueName: imageName)
                    }
                }
            }
        }
    }
}
