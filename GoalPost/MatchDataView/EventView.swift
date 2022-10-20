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

    
    // MARK: Data
    
    var width: CGFloat
    var logoWidth: CGFloat
    
    init(_ event: EventObject?, width: CGFloat, logoWidth: CGFloat) {
        
        self.event = event
        
        self.width = width
        self.logoWidth = logoWidth
        
        super.init(frame: CGRect.zero)
        
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
        
        
        guard event != nil else { return }
        
        setUpUI()
        setUpColors()
        setUpLabels()
        updateContent()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        
        self.constrain(contentView, using: .scale, widthScale: 0.9, heightScale: 0.9)
        contentView.constrain(internalStackView, using: .scale, widthScale: 0.9, heightScale: 0.9)
        
        let imageStack = UIStackView(.horizontal)
        imageStack.add(children: [spacer(0.35), (detailIcon, nil), spacer(nil)])
        
        internalStackView.add(children: [(imageStack, nil), (timeAndDetailsLabel, 0.2), (playerNameLabel, 0.2), (assistingPlayerNameLabel, 0.2), (commentsLabel, 0.2)])
        
    }
    
    func setUpColors() {
        /*
        contentView.layer.borderColor = Colors.cellBorderGreen.cgColor
        contentView.layer.borderWidth = 1
        contentView.layer.cornerRadius = 5
         */
    }
    
    func setUpLabels() {
        
        allLabels.forEach {
            $0.font = UIFont.systemFont(ofSize: 12)
            $0.adjustsFontSizeToFitWidth = true
            $0.textColor = .white
            $0.textAlignment = .center
            $0.numberOfLines = -1
        }
    }
    
    func updateContent() {
        guard let event = event else { fatalError() }
        
        timeAndDetailsLabel.text = "\(event.timeElapsed)'\(event.extraTimeElapsed != nil ? " +\(event.extraTimeElapsed!)" : "")  \(event.eventDetail)"
        
        if event.eventType == .subst {
            playerNameLabel.text = "Out: \(event.playerName ?? "")"
        } else {
            playerNameLabel.text = "\(event.playerName ?? "")"
        }
        
        if let assist = event.assistingPlayerName {
            if event.eventType == .goal {
                assistingPlayerNameLabel.text = "\(assist) (asst)"
            } else if event.eventType == .subst {
                assistingPlayerNameLabel.text = "In: \(assist)"
            }

        } else {
            assistingPlayerNameLabel.isHidden = true
        }

        if let comment = event.comments {
            commentsLabel.text = comment
        } else {
            commentsLabel.isHidden = true
        }

        
        
        
        guard let imageName = event.imageName else {
            print("EventView - Cannot Get Image Name")
            return
        }
        
        print(imageName)
        
        guard let image = UIImage(named: imageName) else {
            print("EventView - Cannot Get Image")
            return
        }
        
        detailIcon.widthAnchor.constraint(equalToConstant: logoWidth).isActive = true
        detailIcon.heightAnchor.constraint(equalToConstant: logoWidth).isActive = true
        
        self.detailIcon.image = image

    }
}
