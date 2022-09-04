//
//  UpdateTimer.swift
//  GoalPost
//
//  Created by Moses Harding on 8/30/22.
//

import Foundation
import UIKit


class UpdateTimer {
    
    static var helper = UpdateTimer()
    
    unowned var rootController: UITabBarController?
    
    func executeTimer(_ completion: @escaping (() -> ())) {
        
        //guard Testing.manager.getLiveData else { return }
        
        guard let rootController = rootController else {
            fatalError("Update Timer - RootController not passed")
        }
        
        if rootController.selectedIndex == 0 {
            
            completion()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) { [weak self] in
                self?.executeTimer(completion)
            }
        } else {
            print("UpdateTimer - executeTimer Terminated")
        }
    }
}
