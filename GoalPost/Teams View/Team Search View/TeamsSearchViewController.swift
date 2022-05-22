//
//  TeamsSearchViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit

class TeamsSearchViewController: UIViewController {
    
    var teamsSearchView = TeamSearchView()
    
    var refreshableParent: Refreshable?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(teamsSearchView)
        
        teamsSearchView.viewController = self
    }
}
