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
        
        //matchesView.setUpDataSourceSnapshots(from: matchesView.currentDate)
        
        for fixtureAd in GAD.helper.fixtureAds {
            GAD.helper.bannerViews[fixtureAd]?.rootViewController = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        matchesView.refresh(update: false)
    }
}

