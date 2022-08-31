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

        testing()
        
        self.setViewControllers([matchesViewController, teamsViewController, leaguesViewController], animated: true)
        self.tabBar.unselectedItemTintColor = UIColor.lightGray
        self.tabBar.tintColor = Colors.green.hex18EE88
        
        matchesViewController.tabBarItem = UITabBarItem(title: "Matches", image: UIImage(systemName: "sportscourt"), tag: 0)
        teamsViewController.tabBarItem = UITabBarItem(title: "Teams", image: UIImage(systemName: "tshirt"), tag: 1)
        leaguesViewController.tabBarItem = UITabBarItem(title: "Leagues", image: UIImage(systemName: "rosette"), tag: 2)

        self.selectedIndex = 0
        
        UpdateTimer.helper.rootController = self
        
        gatherData()
    }
    
    func testing() {
        //clearData()
        
        Task.init {
            print("Favorite leagues - \(await Cached.data.favoriteLeaguesDictionary.values)")
            print("Favorite teams - \(await Cached.data.favoriteTeamsDictionary.values)")
        }
    }
    
    func gatherData() {
        
        // Populate default data if first run
        DataFetcher.helper.fetchDataIfValid()

    }
    
    func clearData() {
        
        Saved.firstRun = true
        
        Task.init {
            await Cached.data.clearData()
        }
    }
}
