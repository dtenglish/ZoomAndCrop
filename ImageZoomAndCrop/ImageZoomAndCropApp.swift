//
//  ImageZoomAndCropApp.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/3/22.
//

import SwiftUI

@main
struct ImageZoomAndCropApp: App {
    var body: some Scene {
        WindowGroup {
            GeometryReader { geometry in
                ContentView()
                    .environment(\.screenSize, geometry.size)
                    .onAppear {
                        print("screen size: \(geometry.size)")
                    }
            }
            .ignoresSafeArea()
        }
    }
}
