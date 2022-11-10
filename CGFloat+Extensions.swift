//
//  CGFloat+Extensions.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/9/22.
//

import UIKit

extension CGFloat {
    func pixelsToPoints() -> CGFloat {
        return self / UIScreen.main.scale
    }
}
