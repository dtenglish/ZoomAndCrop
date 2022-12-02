//
//  UIImage+Extensions.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 11/11/22.
//

import SwiftUI

extension UIImage {    
    var imageOrientation: OrientationFormat {
        if self.size.height >= self.size.width {
            return .portrait
        } else {
            return .landscape
        }
    }
    
    var longSide: CGFloat {
        if imageOrientation == .portrait {
            return self.size.height
        } else {
            return self.size.width
        }
    }
    
    var shortSide: CGFloat {
        if imageOrientation == .portrait {
            return self.size.width
        } else {
            return self.size.height
        }
    }
    
    func fixOrientation() -> UIImage {
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return self
        }
        UIGraphicsEndImageContext()
        return image
    }
}
