//
//  EnvironmentValues.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 10/27/22.
//

import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var screenSize: CGSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}
