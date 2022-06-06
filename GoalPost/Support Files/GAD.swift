//
//  GAD.swift
//  GoalPost
//
//  Created by Moses Harding on 5/26/22.
//

import Foundation
import GoogleMobileAds


struct GAD {
    static var helper = GAD()
    
    var bannerViews = [AdViewName:GADBannerView]()
    
    var matchAds: [AdViewName] = [.matchAd1, .matchAd2, .matchAd3, .matchAd4, .matchAd5]
    
    init() {
        setUpBannerViews()
    }
    
    mutating func setUpBannerViews() {
 
        for name in AdViewName.allCases {
            let adView = GADBannerView()
            adView.adUnitID = Secure.adUnitID
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            bannerView.backgroundColor = Colors.backgroundColor
            
            if !Testing.manager.disableAds {
                bannerView.load(GADRequest())
            }
        }
    }
}
