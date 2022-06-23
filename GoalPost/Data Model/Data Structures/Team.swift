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

    var leagueSet = Set<LeagueID>()
    
    // This should be used for searching
    func mostRecentSeason() async -> Int? {
        
        var season: Int?
        // Iterate through the league dictionary and return the most recent league
        for leagueId in leagueSet {

            let league = await Cached.data.leagueDictionary(leagueId)
            if let leagueSeason = league?.currentSeason {
                if let currentSeason = season {
                    if leagueSeason > currentSeason {
                        season = leagueSeason
                    }
                } else {
                    season = leagueSeason
                }
            }
            }

        return season
    }
    
    // Returned on Team Search
    
    var founded: Int?
    
    init(id: Int, name: String, logo: String? = nil) {
        self.id = id
        self.name = name
        self.logo = logo
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

extension TeamObject: CustomStringConvertible {
    var description: String {
        return "\(self.name) - \(self.id)"
    }
}
