//
//  ViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation
import UIKit

class RootController: UITabBarController {
    
    let matchesViewController = MatchesViewController()
    let teamsViewController = TeamsViewController()
    let leaguesViewController = LeaguesViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setViewControllers([matchesViewController, teamsViewController, leaguesViewController], animated: true)
        self.tabBar.tintColor = Colors.green.hex18EE88
        
        matchesViewController.tabBarItem = UITabBarItem(title: "Matches", image: UIImage(systemName: "sportscourt"), tag: 0)
        teamsViewController.tabBarItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "tshirt"), tag: 1)
        leaguesViewController.tabBarItem = UITabBarItem(title: "Leagues", image: UIImage(systemName: "rosette"), tag: 2)

        self.selectedIndex = 1
        
        //clearData()
        
        gatherData()
    }
    
    func gatherData() {
        
        // Populate default data if first run
        
        if Saved.firstRun {
        
            Cached.leagues  = [39, 61, 78, 135, 140]
            
            // Run the initial data gathering checks
            
            LeagueSearchDataContainer.helper.search()
            MatchesDataContainer.helper.retrieveMatchesFromFavoriteLeagues(update: false)
            
            Saved.lastLeaguesUpdate = Date.now
            Saved.firstRun = false
            
            return
        } else {
            // If not, retrieve data if valid time frame
            if Date.now.timeIntervalSince(Saved.lastLeaguesUpdate) >= 86400 {
                print("\n\n***\n***\n***Running league update since time interval was - \(Date.now.timeIntervalSince(Saved.lastLeaguesUpdate))\n***\n***\n***")
                LeagueSearchDataContainer.helper.search()
                MatchesDataContainer.helper.retrieveMatchesFromFavoriteLeagues(update: false)
                
                Saved.lastLeaguesUpdate = Date.now
            }
        }
    }
    
    func clearData() {
        Saved.firstRun = true
        Cached.matches = [:]
        Cached.favoriteTeamMatches = [:]
        Cached.leagues = []
        Cached.teams = []
    }
}
