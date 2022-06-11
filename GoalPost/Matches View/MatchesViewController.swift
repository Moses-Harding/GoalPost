//
//  ViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import UIKit

class MatchesViewController: UIViewController {
    
    var matchesView = MatchesView()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the views
        
        self.view.constrain(matchesView)

        for matchAd in GAD.helper.matchAds {
            GAD.helper.bannerViews[matchAd]?.rootViewController = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        matchesView.refresh()
    }
}

