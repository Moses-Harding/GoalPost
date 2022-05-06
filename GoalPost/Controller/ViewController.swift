//
//  ViewController.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import UIKit

class ViewController: UIViewController {
    
    var mainScreenView = MainScreenView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.constrain(mainScreenView)
    }


}

