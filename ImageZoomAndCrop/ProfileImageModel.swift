//
//  ProfileImageModel.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 10/28/22.
//

import SwiftUI

struct ProfileImage {
    var imageData: Data?
    var croppedImageData: Data?
    var scale: Double = 0
    var position: CGSize = .zero
    var width: Double {
        return Double(position.width)
    }
    var height: Double {
        return Double(position.height)
    }
//
//    var position: CGSize {
//        return CGSize(width: width, height: height)
//    }
    
//    var uiImage: UIImage? {
//        if imageData != nil,
//           let image = UIImage(data: imageData!) {
//            return image
//        } else {
//            return nil
//        }
//    }
}
