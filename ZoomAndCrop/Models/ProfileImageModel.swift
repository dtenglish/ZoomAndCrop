//
//  ProfileImageModel.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 10/28/22.
//

import SwiftUI

struct ProfileImage {
    var imageData: Data?
    var croppedImageData: Data?
    var scale: Double = 0
    var position: CGSize = .zero
}
