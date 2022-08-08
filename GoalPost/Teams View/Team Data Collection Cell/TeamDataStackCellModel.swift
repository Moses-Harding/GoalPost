//
//  TeamDataStackCellModel.swift
//  GoalPost
//
//  Created by Moses Harding on 6/12/22.
//

import Foundation
import UIKit

/*
 DOCUMENTATION
 
 All cells that live in the collectionView in the TeamDataStack are subclasses of this class. This class primarily handles the "loading" functionality.
 
 1. ConctentView adds MainStack, which contains both "contentStack" and "LoadingView"
 2. LoadingView is hidden by default
 3. When a teamDataObject is assigned to the cell, checkForContent() fires. If the teamDataObject has the property "loading", then the contentView is hidden, the loadingView is unhidden, and the loading(true) method is called. Otherwise, the reverse happens, and the function "updateContent" is called (which is overrided on a subclass level).
 4. If loading(true) is called, start animating the indicator (waiting wheel); otherwise do the reverse.
 
 */

class TeamDataStackCellModel: UICollectionViewCell {
    
    // MARK: Data
    
    var teamDataObject: TeamDataObject? { didSet { checkForContent() } }
    
    // MARK: Indicator
    
    var indicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .large
        return view
    } ()
    
    // MARK: Stacks
    
    var mainStack = UIStackView(.vertical)
    var contentStack = UIStackView(.vertical)
    
    // MARK: Loading
    
    var loadingView = UIView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpMainStack()
        setUpLoadingView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpMainStack()
        setUpLoadingView()
    }
    
    func setUpMainStack() {
        contentView.constrain(mainStack, using: .edges, padding: 10, debugName: "MainStack To ContentView - TeamDataStackCellModel")
        
        mainStack.add([contentStack, loadingView])
        
        layer.cornerRadius = 15
        layer.borderColor = Colors.teamDataStackCellBorderColor.cgColor
        layer.borderWidth = 1
    }
    
    func setUpLoadingView() {

        loadingView.constrain(indicator)
        loadingView.isHidden = true
    }
    
    func checkForContent() {
        
        guard let teamDataObject = teamDataObject else { return }
        
        if teamDataObject.loading {
            loadingView.isHidden = false
            contentStack.isHidden = true
            self.loading(true)
        } else {
            loadingView.isHidden = true
            contentStack.isHidden = false
            self.loading(false)
            self.updateContent()
        }
    }
    
    func updateContent() {
        // Override this
    }
    
    func loading(_ loading: Bool) {
        if loading {
            self.backgroundColor = UIColor.clear
            self.indicator.startAnimating()
        } else {
            self.backgroundColor = Colors.teamDataStackCellBackgroundColor
            self.indicator.stopAnimating()
        }

    }
}
