//
//  Custom Classes.swift
//  GoalPost
//
//  Created by Moses Harding on 4/23/22.
//

import Foundation
import UIKit

class AutoSizedCollectionView: UICollectionView {

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

// This was created to solve problems related to expanding cells in a collecitonview
class CustomStack: UIView {
    
    var axis: NSLayoutConstraint.Axis
    var spacing: CGFloat
    var distribution: UIStackView.Distribution
    var alignment: UIStackView.Alignment
    
    /* This conveniene init is simply to facilitate the more common usages of UIStackView */
    init(_ axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0, isLayoutMarginsRelativeArrangement: Bool = true, distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill) {
        
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addArrangedSubview(_ view: UIView) {
        
        if let lastView = self.subviews.last {
            if self.axis == .horizontal {
                self.constrain(view, using: .edges, except: [.leading, .trailing], debugName: "CustomStack")
                view.leadingAnchor.constraint(equalTo: lastView.trailingAnchor).isActive = true
            } else {
                self.constrain(view, using: .edges, except: [.top, .bottom], debugName: "CustomStack")
                view.topAnchor.constraint(equalTo: lastView.bottomAnchor).isActive = true
            }
        } else {
            if self.axis == .horizontal {
                self.constrain(view, using: .edges, except: [.leading, .trailing], debugName: "CustomStack")
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            } else {
                self.constrain(view, using: .edges, except: [.top, .bottom], debugName: "CustomStack")
                view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            }
        }
    }
    
    /* Add: Add a list of views to a stackview and optionally provide percentages to scale each of the children. By default, if the percentages exceed 100, an error will be thrown. */
    func add(children: [(UIView, CGFloat?)], overrideErrorCheck: Bool = false) {
        
        var count: CGFloat = 0
        
        var constraintType: ConstraintType
        
        if self.axis == .horizontal {
            constraintType = .width
        } else {
            constraintType = .height
        }
        
        for (child, multiplier) in children {
            self.addArrangedSubview(child)
            if let multiplier = multiplier {
                self.setConstraint(for: child, constraintType, multiplier: (multiplier - 0.01))
                count += multiplier
            }
        }
        
        guard count <= 1 || overrideErrorCheck == true else {
            fatalError("Stack constraints exceed 100%")
        }
    }
    
    func add(_ children: [UIView]) {
        for child in children {
            self.addArrangedSubview(child)
        }
    }
}

class Indicator: UIActivityIndicatorView {
    
}
