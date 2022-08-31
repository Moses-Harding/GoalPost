//
//  LeagueSearchViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/12/22.
//

import Foundation
import UIKit

class LeagueSearchViewController: UIViewController {
    
    var leagueSearchView = LeagueSearchView()
    
    var delegate: LeaguesViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(leagueSearchView)
        
        leagueSearchView.viewController = self
    }
}
