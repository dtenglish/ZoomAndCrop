//
//  EnvironmentValues.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 10/27/22.
//

import SwiftUI

private struct ScreenSizeKey: EnvironmentKey {
    static let defaultValue = ViewSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
}

extension EnvironmentValues {
    var screenSize: ViewSize {
        get { self[ScreenSizeKey.self] }
        set { self[ScreenSizeKey.self] = newValue }
    }
}
