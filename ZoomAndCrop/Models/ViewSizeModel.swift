//
//  ViewSizeModel.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 12/2/22.
//

import SwiftUI

struct ViewSize {
    var width: CGFloat
    var height: CGFloat
    
    var orientation: OrientationFormat {
        if height >= width {
            return .portrait
        } else {
            return .landscape
        }
    }
    
    var longSide: CGFloat {
        if orientation == .portrait {
            return height
        } else {
            return width
        }
    }
    
    var shortSide: CGFloat {
        if orientation == .portrait {
            return width
        } else {
            return height
        }
    }
}
