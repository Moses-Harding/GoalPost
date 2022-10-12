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
    
    func updateMatches(refreshClosure: @escaping (() -> ()), updateClosure: @escaping (() -> ()), initiated: String? = nil) {
        
        //guard Testing.manager.getLiveData else { return }
        
        guard let rootController = rootController else {
            fatalError("Update Timer - RootController not passed")
        }
        
        let initiatedTime = initiated ?? Date.now.formatted(date: .abbreviated, time: .shortened)
        
        if rootController.selectedIndex == 0 {
            
            if refreshMatchesView {
                refreshClosure()
                refreshMatchesView = false
            } else {
                updateClosure()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) { [weak self] in
                
                print("UpdateTimer - UpdateMatches - Triggered By Instance At \(initiatedTime)")
                self?.updateMatches(refreshClosure: refreshClosure, updateClosure: updateClosure, initiated: initiatedTime)
            }
        } else {
            print("UpdateTimer - executeTimer Terminated")
        }
    }
}
