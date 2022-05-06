//
//  UIView.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

/* Enums for reference:
 
ConstraintType - height, width, centerX, centerY, leading, trailing, top, bottom
ConstraintMethod - scale, edges

 */

extension UIView {
    
    //MARK: Constraining subviews
    //The purpose of the  below is to reduce the overhead of programmatically constraining a subview to a view (setting defaults, defining four constraints, and activating them).
    
    /* Constrain: Automatically constrain a child view either by scaling to proportions of parent view or by fitting to edges (with padding). User can specify exceptions. The generated constraints are returned if needed (including exceptions, which are inactive). */
    @discardableResult
    func constrain(_ child: UIView, using constraintMethod: ConstraintMethod = .scale, widthScale: CGFloat = 1, heightScale: CGFloat = 1, padding: CGFloat = 0, except: [ConstraintType] = [], safeAreaLayout: Bool = false, debugName: String = "Unnamed View") -> (NSLayoutConstraint, NSLayoutConstraint, NSLayoutConstraint, NSLayoutConstraint) {
        
        child.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(child)
        
        let safeArea: UILayoutGuide? = safeAreaLayout ? self.safeAreaLayoutGuide : nil

        let heightConstraint = child.heightAnchor.constraint(equalTo: safeArea?.heightAnchor ?? self.heightAnchor, multiplier: heightScale)
        let widthConstraint = child.widthAnchor.constraint(equalTo: safeArea?.widthAnchor ?? self.widthAnchor, multiplier: widthScale)
        let centerYConstraint = child.centerYAnchor.constraint(equalTo: safeArea?.centerYAnchor ?? self.centerYAnchor)
        let centerXConstraint = child.centerXAnchor.constraint(equalTo: safeArea?.centerXAnchor ?? self.centerXAnchor)
        let leadingConstraint = child.leadingAnchor.constraint(equalTo: safeArea?.leadingAnchor ?? self.leadingAnchor, constant: padding)
        let trailingConstraint = child.trailingAnchor.constraint(equalTo: safeArea?.trailingAnchor ?? self.trailingAnchor, constant: -padding)
        let topConstraint = child.topAnchor.constraint(equalTo: safeArea?.topAnchor ?? self.topAnchor, constant: padding)
        let bottomConstraint = child.bottomAnchor.constraint(equalTo: safeArea?.bottomAnchor ?? self.bottomAnchor, constant: -padding)
        
        centerXConstraint.identifier = "\(debugName) - Custom Constraint - Center X"
        centerYConstraint.identifier = "\(debugName) - Custom Constraint - Center Y"
        widthConstraint.identifier = "\(debugName) - Custom Constraint - Width"
        heightConstraint.identifier = "\(debugName) - Custom Constraint - Height"
        leadingConstraint.identifier = "\(debugName) - Custom Constraint - Leading"
        trailingConstraint.identifier = "\(debugName) - Custom Constraint - Trailing"
        topConstraint.identifier = "\(debugName) - Custom Constraint - Top"
        bottomConstraint.identifier = "\(debugName) - Custom Constraint - Bottom"
        
        var constraintTuple: (NSLayoutConstraint, NSLayoutConstraint, NSLayoutConstraint, NSLayoutConstraint)
        
        if constraintMethod == .scale {
            NSLayoutConstraint.activate([heightConstraint, widthConstraint, centerYConstraint, centerXConstraint])
        
            constraintTuple = (centerXConstraint: centerXConstraint, centerYConstraint: centerYConstraint, widthConstraint: widthConstraint, heightConstraint: heightConstraint)
        } else {
            NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
            
            constraintTuple = (leadingConstraint: leadingConstraint, trailingConstraint: trailingConstraint, topConstraint: topConstraint, bottomConstraint: bottomConstraint)
        }
        
        except.forEach { exception in
            switch exception {
            case .height:
                heightConstraint.isActive = false
            case .width:
                widthConstraint.isActive = false
            case .centerX:
                centerXConstraint.isActive = false
            case .centerY:
                centerYConstraint.isActive = false
            case .leading:
                leadingConstraint.isActive = false
            case .trailing:
                trailingConstraint.isActive = false
            case .top:
                topConstraint.isActive = false
            case .bottom:
                bottomConstraint.isActive = false
            }
        }
        
        return constraintTuple
    }
    
    /* SetConstraint: Create and return a single constraint (specified by "constraintType"). Options to add padding and in the case of width/height constraints, scale with a multiplier. Can add as a child if needed. */
    @discardableResult
    func setConstraint(for child: UIView, _ constraintType: ConstraintType, addAsChild: Bool = false, multiplier: CGFloat = 1, constant: CGFloat = 0) -> NSLayoutConstraint {
        
        if addAsChild {
            self.addSubview(child)
            child.translatesAutoresizingMaskIntoConstraints = false
        }
        
        if constraintType != .height && constraintType != .width && multiplier != 1 {
            print("Warning - multiplier has no effect")
        }
        
        var constraint: NSLayoutConstraint
        
        switch constraintType {
        case .top:
            constraint = child.topAnchor.constraint(equalTo: self.topAnchor, constant: constant)
        case .bottom:
            constraint = child.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: constant)
        case .leading:
            constraint = child.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constant)
        case .trailing:
            constraint = child.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: constant)
        case .centerX:
            constraint = child.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: constant)
        case .centerY:
            constraint = child.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: constant)
        case .height:
            constraint = child.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: multiplier, constant: constant)
        case .width:
            constraint = child.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: multiplier, constant: constant)
        }
        
        constraint.isActive = true
        constraint.identifier = "Custom Constraint - \(constraintType)"
        
        return constraint
    }
}

