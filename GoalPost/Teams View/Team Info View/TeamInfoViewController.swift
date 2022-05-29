//
//  TeamInfoViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/26/22.
//

import Foundation
import UIKit

class TeamInfoViewController: UIViewController {
    
    var teamInfoView = TeamInfoView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the views
        
        self.view.constrain(teamInfoView)
        

        GAD.helper.bannerViews[.teamInfoViewBanner]?.rootViewController = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

