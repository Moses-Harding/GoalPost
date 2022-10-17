//
//  MatchDataViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 10/11/22.
//

import Foundation
import UIKit

class MatchDataViewController: UIViewController {
    
    var matchDataView = MatchDataView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.constrain(matchDataView)
        
        matchDataView.viewController = self
    }
}
