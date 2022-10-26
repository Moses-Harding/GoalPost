//
//  LeagueDataViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 8/30/22.
//

import Foundation
import UIKit

class LeagueDataViewController: UIViewController {
    
    var leagueDataView = LeagueDataView()
    var leaguesViewDelegate: LeaguesViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(leagueDataView)
        
        leagueDataView.viewController = self
    }
}
