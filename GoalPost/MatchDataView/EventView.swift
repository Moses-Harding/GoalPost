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
    let iconView = UIView()
    let detailIcon = UIImageView()
    
    var spacer: ((CGFloat?) -> (UIView, CGFloat?)) = {
        return (UIView(), $0)
    }
    
    enum HomeOrAway {
        case home, away
    }

    
    // MARK: Data
    

    var logoWidth: CGFloat
    var homeOrAway: HomeOrAway
    
    init(_ event: EventObject?, logoWidth: CGFloat, homeOrAway: HomeOrAway) {
        
        self.event = event
        
        //self.viewWidth = width
        self.logoWidth = logoWidth
        self.homeOrAway = homeOrAway
        
        super.init(frame: CGRect.zero)
        
        
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
        
        playerNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
    }
    
    func updateContent() {
        guard let event = event else { fatalError() }
        
        let imageStack = UIStackView(.horizontal)
        imageStack.add(children: [spacer(0.35), (iconView, nil), spacer(nil)])
        iconView.constrain(detailIcon, using: .scale, except: [.height])
        
        
        let firstView = homeOrAway == .home ? spacer(nil) : (imageStack, 0.2)
        let lastView = homeOrAway == .home ? (imageStack, 0.2) : spacer(nil)
        
        let smallSpacerSize = 0.1
        let sectionSize = 0.18
        let playerNameLabelSize = 0.23

            switch event.eventType  {
            case .card:
                playerNameLabel.text = "\(event.playerName)"
                timeAndDetailsLabel.text = event.comments != nil ? event.comments! : event.eventDetail
                internalStackView.add(children: [firstView, spacer(smallSpacerSize), (playerNameLabel, playerNameLabelSize), (timeAndDetailsLabel, sectionSize), spacer(smallSpacerSize), lastView])
            case .goal:
                playerNameLabel.text = "\(event.playerName)"
                timeAndDetailsLabel.text = event.eventDetail == "Normal Goal" ? "GOAL!" : "\(event.eventDetail)"
                if let assisting = event.assistingPlayerName {
                    assistingPlayerNameLabel.text = "\(assisting) (asst)"
                    internalStackView.add(children: [firstView, spacer(smallSpacerSize), (playerNameLabel, playerNameLabelSize), (assistingPlayerNameLabel, sectionSize), (timeAndDetailsLabel, sectionSize), spacer(smallSpacerSize), lastView])
                } else {
                    internalStackView.add(children: [firstView, spacer(smallSpacerSize), (playerNameLabel, playerNameLabelSize), (timeAndDetailsLabel, sectionSize), spacer(smallSpacerSize), lastView])
                }
            case .subst:
                playerNameLabel.text = "In: \(event.assistingPlayerName ?? "")"
                assistingPlayerNameLabel.text = "Out: \(event.playerName)"
                internalStackView.add(children: [firstView, spacer(smallSpacerSize), (playerNameLabel, playerNameLabelSize), (assistingPlayerNameLabel, sectionSize), spacer(smallSpacerSize), lastView])
            case .Var:
                playerNameLabel.text = "\(event.playerName)"
                timeAndDetailsLabel.text = event.comments != nil ? event.comments! : event.eventDetail
                internalStackView.add(children: [firstView, spacer(smallSpacerSize), (playerNameLabel, playerNameLabelSize), (timeAndDetailsLabel, sectionSize), spacer(smallSpacerSize), lastView])
            }
        
        guard let imageName = event.imageName else {
            print("EventView - Cannot Get Image Name")
            return
        }
        
        guard let image = UIImage(named: imageName) else {
            print(imageName)
            print("EventView - Cannot Get Image")
            return
        }
        
        detailIcon.widthAnchor.constraint(equalToConstant: logoWidth).isActive = true
        detailIcon.heightAnchor.constraint(equalToConstant: logoWidth).isActive = true
        
        self.detailIcon.image = image

    }
}
