//
//  UIImage.swift
//  GoalPost
//
//  Created by Moses Harding on 8/18/22.
//

import Foundation
import UIKit

extension UIImage {
    
    enum ResizeDimension {
        case width
        case height
    }
    func resize(_ dimension: ResizeDimension, proportionalTo size: CGFloat) -> CGSize {
        
        var height = self.size.height
        var width = self.size.width
        
        switch dimension {
        case .width:
            let heightRatio = CGFloat(size) / height
            width *= heightRatio
        case .height:
            let widthRatio = CGFloat(size) / width
            height *= widthRatio
        }
        
        let size = CGSize(width: width, height: height)
        
        
        return size
    }
}
