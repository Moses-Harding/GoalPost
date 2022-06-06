//
//  TeamsSearchViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit

class TeamSearchViewController: UIViewController {
    
    var teamSearchView = TeamSearchView()
    
    var refreshableParent: TeamsViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(teamSearchView)
        
        teamSearchView.viewController = self
    }
}
