//
//  EventView.swift
//  GoalPost
//
//  Created by Moses Harding on 10/16/22.
//

import Foundation
import UIKit

class EventView: UIView {
    
    var event: EventObject?
    
    var contentView = UIView()
    var internalStackView = UIStackView(.vertical)
    
    // MARK: Labels
    let timeAndDetailsLabel = UILabel()
    let commentsLabel = UILabel()
    let playerNameLabel = UILabel()
    let assistingPlayerNameLabel = UILabel()
    
    var allLabels: [UILabel] {
        return [timeAndDetailsLabel, commentsLabel, playerNameLabel, assistingPlayerNameLabel]
    }
    
    
    // MARK: Images
    let detailIcon = UIImageView()
    
    var spacer: ((CGFloat?) -> (UIView, CGFloat?)) = {
        return (UIView(), $0)
    }

    
    init(_ event: EventObject?) {
        
        self.event = event
        
        super.init(frame: CGRect.zero)
        
        self.widthAnchor.constraint(equalToConstant: 175).isActive = true
        
        
        guard event != nil else { return }
        
        setUpUI()
        setUpColors()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        
        self.constrain(contentView, using: .scale, widthScale: 0.9, heightScale: 0.9)
        contentView.constrain(internalStackView, using: .scale, widthScale: 0.9, heightScale: 0.9)
        
        let imageStack = UIStackView(.horizontal)
        imageStack.add(children: [spacer(0.2), (detailIcon, nil), spacer(nil)])
        
        internalStackView.add([imageStack, timeAndDetailsLabel, playerNameLabel, assistingPlayerNameLabel, commentsLabel])
        
        internalStackView.add(children: [(imageStack, 0.2), (timeAndDetailsLabel, 0.2), (playerNameLabel, 0.2), (assistingPlayerNameLabel, 0.2), (commentsLabel, 0.2)])
        
    }
    
    func setUpColors() {
        contentView.layer.borderColor = Colors.cellBorderGreen.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 5
    }
    
    func setUpLabels() {
        
        allLabels.forEach {
            $0.font = UIFont.systemFont(ofSize: 10)
            $0.adjustsFontSizeToFitWidth = true
            $0.textColor = .white
        }
    }
    
    func updateContent() {
        guard let event = event else { fatalError() }
        
        timeAndDetailsLabel.text = "\(event.timeElapsed)'\(event.extraTimeElapsed != nil ? " (\(event.extraTimeElapsed!))" : " ")  \(event.eventDetail)"
        playerNameLabel.text = "\(event.playerName ?? " ")"
        assistingPlayerNameLabel.text = "\(event.assistingPlayerName ?? " ")"
        commentsLabel.text = "\(event.comments ?? " ")"
        
        if let imageName = event.imageName {
            self.detailIcon.image = UIImage(named: imageName)
        }
    }
}
