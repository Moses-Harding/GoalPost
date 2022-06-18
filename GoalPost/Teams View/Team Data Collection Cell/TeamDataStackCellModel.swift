//
//  TeamDataStackCellModel.swift
//  GoalPost
//
//  Created by Moses Harding on 6/12/22.
//

import Foundation
import UIKit

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
