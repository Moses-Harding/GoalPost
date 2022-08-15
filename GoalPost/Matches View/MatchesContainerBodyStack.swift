//
//  MatchesViewCollectionCellBodyStack.swift
//  GoalPost
//
//  Created by Moses Harding on 8/12/22.
//
import Foundation
import UIKit

class MatchesContainerBodyStack: UIStackView {
    

    let collectionViewArea = UIView()
    //var totalHeight: CGFloat = 1200
    var totalHeight: CGFloat = 300
    var objectContainer: ObjectContainer?
    
    init(objectContainer: ObjectContainer?) {
        super.init(frame: .zero)
        
        self.objectContainer = objectContainer

        self.axis = .vertical
        
        setUpMainStack()
        setUpColors()
    }
    
    // 1
    func setUpMainStack() {
        // Set Up Structure
        self.add([collectionViewArea])
        
        self.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight).isActive = true
    }
    
    // 3
    func setUpColors() {

        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
