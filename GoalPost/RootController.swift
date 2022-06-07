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

        self.selectedIndex = 1

        
        gatherData()
    }
    
    func testing() {
        // clearData()
        
        //print(Cached.favoriteTeamIds)
        //print(Cached.matchesDictionary)
        //print(Cached.favoriteMatchesByDateSet)
        
        /*
        print(
        Cached.teamDictionary,
        Cached.leagueDictionary,
        Cached.matchesDictionary,
        Cached.injuryDictionary,
        Cached.playerDictionary,
        Cached.transferDictionary,
        Cached.injuriesByTeam,
        Cached.matchesByTeam,
        Cached.transfersByTeam)
        */
        
        // DataFetcher.helper.testing(team: 529)
        
        // print(Cached.injuriesByTeam)
        
        // Cached.favoriteTeamIds = []
        
        //print(Cached.transferDictionary, Cached.transfersByTeam)
        
        //Cached.transferDictionary = [:]
        //Cached.transfersByTeam = [:]
        

        for team in Cached.favoriteTeamIds {
            //GetLeagues.helper.getLeaguesFrom(team: 3520)
            //Cached.teamDictionary[3520]?.leagueDictionary.values.forEach {
            //    print($0.name, $0.country, $0.id, $0.currentSeason)
            //}
        }
        /*
        Task.init {
            guard let team = Cached.teamDictionary[3520] else { fatalError() }
            let foundTeam = try await GetLeagues.helper.getLeaguesFrom(team: team)
            print("Retrieved \(foundTeam) with dict \(foundTeam.leagueDictionary)")
        }
         */
    }
    
    func gatherData() {
        
        // Populate default data if first run
        
        if Saved.firstRun {
            
            print("\nFirst Run\n")
        
            Cached.favoriteLeagueIds  = [39, 61, 78, 135, 140]
            Saved.firstRun = false
            
            
            DataFetcher.helper.fetchDataIfValid(true)
            
            return
        } else {
            DataFetcher.helper.fetchDataIfValid(false)
        }
    }
    
    func clearData() {
        
        Saved.firstRun = true
        
        Cached.favoriteLeagueIds = []
        Cached.favoriteTeamIds = []
        
        Cached.favoriteMatchesByDateSet = [:]
        Cached.favoriteMatchesDictionary = [:]
        
        Cached.matchesByDateSet = [:]
        Cached.matchesByLeagueSet = [:]
        Cached.matchesByTeam = [:]
        
        Cached.injuriesByTeam = [:]
        Cached.transfersByTeam = [:]

        Cached.teamDictionary = [:]
        Cached.leagueDictionary = [:]
        Cached.matchesDictionary = [:]
        Cached.injuryDictionary = [:]
        Cached.playerDictionary = [:]
        Cached.transferDictionary = [:]
    }
}
