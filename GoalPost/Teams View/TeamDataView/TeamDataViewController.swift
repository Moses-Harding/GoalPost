//
//  TeamDataViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 8/15/22.
//

import Foundation
import UIKit

class TeamDataViewController: UIViewController {
    
    var teamDataView = TeamDataView()
    var teamsViewDelegate: TeamsViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(teamDataView)
        
        teamDataView.viewController = self
    }
}
