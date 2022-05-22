//
//  Secure.swift
//  GoalPost
//
//  Created by Moses Harding on 5/8/22.
//

import Foundation
import GoogleMobileAds

struct Secure {
    static var rapidAPIKey = "80366ba3ddmshe3b5a012c9c5ff6p1785b2jsn4a2542dae833"
}

enum AdViewName: String, Codable, CaseIterable {
    case teamsViewBanner
    case leaguesViewBanner
    case fixtureAd1
    case fixtureAd2
    case fixtureAd3
    case fixtureAd4
    case fixtureAd5
}

struct GAD {
    static var helper = GAD()
    
    var bannerViews = [AdViewName:GADBannerView]()
    
    var fixtureAds: [AdViewName] = [.fixtureAd1, .fixtureAd2, .fixtureAd3, .fixtureAd4, .fixtureAd5]
    
    init() {
        setUpBannerViews()
    }
    
    mutating func setUpBannerViews() {
 
        for name in AdViewName.allCases {
            let adView = GADBannerView()
            adView.adUnitID = "ca-app-pub-3940256099942544/2435281174"
            self.bannerViews[name] = adView
        }
    }
    
    func setUpNativeViews() {
        
    }
    
    func initialize() {
        
         GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
         "632d9823aa0c43c25c034cf311d36076", GADSimulatorID as String
         ]
        
        GADMobileAds.sharedInstance().start()
    }
    
    func loadBannerAd(for viewName: AdViewName, with width: CGFloat?) {
        
        print("Loading ad for \(viewName)")
        
        guard var bannerView = bannerViews[viewName] else {
            fatalError( "No banner view found with name \(viewName)")
        }
        
        DispatchQueue.main.async {
            bannerView.backgroundColor = Colors.backgroundColor
            
            bannerView.load(GADRequest())
        }
    }
}
