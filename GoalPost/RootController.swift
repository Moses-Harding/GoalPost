//
//  ViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/11/22.
//

import Foundation
import UIKit

class RootController: UITabBarController {
    
    lazy var matchesViewController = MatchesViewController()
    lazy var teamsViewController = TeamsViewController()
    lazy var leaguesViewController = LeaguesViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //clearData()
        
        self.setViewControllers([matchesViewController, teamsViewController, leaguesViewController], animated: true)
        self.tabBar.tintColor = Colors.green.hex18EE88
        
        matchesViewController.tabBarItem = UITabBarItem(title: "Matches", image: UIImage(systemName: "sportscourt"), tag: 0)
        teamsViewController.tabBarItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "tshirt"), tag: 1)
        leaguesViewController.tabBarItem = UITabBarItem(title: "Leagues", image: UIImage(systemName: "rosette"), tag: 2)

        self.selectedIndex = 1

        
        gatherData()
    }
    
    func gatherData() {
        
        // Populate default data if first run
        
        if Saved.firstRun {
            
            print("\n\n***\n***\n***RUNNING LEAGUE search since first run\n***\n***\n***\n")
        
            Cached.leagues  = [39, 61, 78, 135, 140]
            
            // Run the initial data gathering checks
            
            GetLeagues.helper.getAllLeagues()
            DataFetcher.helper.getDataforFavoriteLeagues()
            
            Saved.lastLeaguesUpdate = Date.now
            Saved.firstRun = false
            
            return
        } else {
            // If not, retrieve data if valid time frame
            DataFetcher.helper.fetchDataIfValid()
        }
    }
    
    func clearData() {
        
        Saved.firstRun = true
        
        Cached.leagues = []
        Cached.teams = []
        

        Cached.teamDictionary = [:]
        Cached.leagueDictionary = [:]
        Cached.matchesDictionary = [:]
        Cached.injuryDictionary = [:]
        Cached.playerDictionary = [:]
        
        Cached.injuriesByTeam = [:]
        Cached.matchesByTeam = [:]
        
        Cached.matchesByDay = [:]
        Cached.favoriteTeamMatchesByDay = [:]

    }
}
