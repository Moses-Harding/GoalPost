//
//  Team.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class TeamObject: Codable {
    
    var id: TeamID
    var name: String
    var code: String?
    var country: String?
    var national: Bool = false
    var logo: String?
    
    var leagueDictionary: [Int:LeagueObject] = [:]
    
    // This should be used for searching
    lazy var mostRecentSeason: Int = {
        var season: Int = 0
        
        // Iterate through the league dictionary and return the most recent league
        for league in leagueDictionary.values {
            if league.currentSeason ?? 0 > season {
                season = league.currentSeason ?? 0
            }
        }
        
        // If none are found (in case no leagues have been added yet), just use this year
        if season == 0 {
            return Calendar.current.component(.year, from: Date.now)
        } else {
            return season
        }
    } ()
    
    // Returned on Team Search
    
    var founded: Int?
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    convenience init(teamSearchInformation: TeamSearchInformation) {
    
        self.init(id: teamSearchInformation.team.id, name: teamSearchInformation.team.name)
    
        self.code = teamSearchInformation.team.code
        self.country = teamSearchInformation.team.country
        self.national = teamSearchInformation.team.national
        self.logo = teamSearchInformation.team.logo
        self.founded = teamSearchInformation.team.founded
    }
    
    convenience init(getMatchInfoTeam: GetMatchInformation_Teams_Team) {
        
        self.init(id: getMatchInfoTeam.id, name: getMatchInfoTeam.name)
        
        self.logo = getMatchInfoTeam.logo
    }
    
    convenience init(getInjuriesInformationTeam: GetInjuriesInformation_Team) {
        
        self.init(id: getInjuriesInformationTeam.id, name: getInjuriesInformationTeam.name)
        
        self.logo = getInjuriesInformationTeam.logo
    }
}

extension TeamObject: Hashable {
    static func == (lhs: TeamObject, rhs: TeamObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
