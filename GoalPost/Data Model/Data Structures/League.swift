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
    
    var details: String {
        var details = "Name: \(name) - Country: \(country)\n\(countryLogo)"
        return details
    }

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

/* NOTE: Country logos are downloaded via a web service call that only gets countries. They're then saved in the assets folder because they're SVGs. This is done via applescript - listed below:
 
 tell application "Numbers"
     
     set filenames to value of every cell of range "A1:A163" of table 1 of sheet 1 of document 1
     
     set URLs to value of every cell of range "B1:B163" of table 1 of sheet 1 of document 1
     
 end tell



 repeat with i from 1 to count URLs
     
     if (item i of filenames is not missing value) and (item i of URLs is not missing value) then
         
         set thisFname to quoted form of (POSIX path of ((path to desktop) as text) & item i of filenames)
         
         set thisUrl to quoted form of item i of URLs
         
         
         
         do shell script "curl -s -o " & thisFname & space & thisUrl
         
         
         
     end if
     
 end repeat
 
 */
