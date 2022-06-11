//
//  League.swift
//  GoalPost
//
//  Created by Moses Harding on 5/25/22.
//

import Foundation

class LeagueObject: Codable {

    var id: LeagueID
    var name: String
    var logo: String?
    var type: LeagueSearchInformation_League_Type?
    var country: String
    var countryLogo: String?
    var currentSeason: Int?
    var seasonStart: String?
    var seasonEnd: String?
    var round: String?

    init(id: Int, name: String, logo: String? = nil, type: LeagueSearchInformation_League_Type? = nil, country: String, countryLogo: String? = nil, currentSeason: Int? = nil, seasonStart: String? = nil, seasonEnd: String? = nil, round: String? = nil) {
        self.id = id
        self.name = name
        self.logo = logo
        self.type = type
        self.country = country
        self.countryLogo = countryLogo
        self.currentSeason = currentSeason
        self.seasonStart = seasonStart
        self.seasonEnd = seasonEnd
        self.round = round
    }
    
    convenience init(getMatchInformationLeague: GetMatchInformation_League) {
        
        self.init(id: getMatchInformationLeague.id, name: getMatchInformationLeague.name, logo: getMatchInformationLeague.logo, country: getMatchInformationLeague.country, countryLogo: getMatchInformationLeague.flag, currentSeason: getMatchInformationLeague.season, round: getMatchInformationLeague.round)
    }
    
    convenience init(getInjuriesInformationLeague info: GetInjuriesInformation_League) {

        self.init(id: info.id, name: info.name, logo: info.logo, country: info.country, currentSeason: info.season)
    }
}

extension LeagueObject: Hashable {
    static func == (lhs: LeagueObject, rhs: LeagueObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension LeagueObject: CustomStringConvertible {
    var description: String {
        return "\(self.name) - \(self.id)"
    }
}
