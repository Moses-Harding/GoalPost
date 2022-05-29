//
//  TeamsViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 5/10/22.
//

import Foundation
import UIKit

class TeamsViewController: UIViewController {
    
    var teamsView = TeamsView()
    var adView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        addViews()
        
        teamsView.viewController = self
        
        GAD.helper.bannerViews[.teamsViewBanner]?.rootViewController = self
        
        addAdView()
    }
    
    func addViews() {
        self.view.constrain(adView, using: .scale, widthScale: 1, heightScale: 0.1, padding: 0, except: [.centerY], safeAreaLayout: true, debugName: "TeamsView - AdView")
        adView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        adView.backgroundColor = Colors.white.hexFFFCF9
        
        self.view.constrain(teamsView, using: .scale, widthScale: 1, except: [.height, .centerY], safeAreaLayout: true, debugName: "TeamsView - TeamsView")
        teamsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        teamsView.bottomAnchor.constraint(equalTo: adView.topAnchor).isActive = true
        
        guard let bannerView = GAD.helper.bannerViews[.teamsViewBanner] else { fatalError("TeamsViewBanner was not initialized") }
        
        adView.constrain(bannerView)
    }
    
    func addAdView() {

        let width = view.frame.inset(by: view.safeAreaInsets)
        
        GAD.helper.loadBannerAd(for: .teamsViewBanner, with: width.width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addAdView()
    }
    
    override func viewWillTransition(
      to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator
    ) {
      coordinator.animate(alongsideTransition: { _ in
          self.addAdView()
      })
    }
}
