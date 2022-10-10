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
    
    var refreshMatchesView = false
    
    func updateMatches(refreshClosure: @escaping (() -> ()), updateClosure: @escaping (() -> ())) {
        
        //guard Testing.manager.getLiveData else { return }
        
        guard let rootController = rootController else {
            fatalError("Update Timer - RootController not passed")
        }
        
        if rootController.selectedIndex == 0 {
            
            if refreshMatchesView {
                refreshClosure()
                refreshMatchesView = false
            } else {
                updateClosure()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
                self?.updateMatches(refreshClosure: refreshClosure, updateClosure: updateClosure)
            }
        } else {
            print("UpdateTimer - executeTimer Terminated")
        }
    }
}
