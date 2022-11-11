//
//  UIImage+Extensions.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/11/22.
//

import SwiftUI

extension UIImage {
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
