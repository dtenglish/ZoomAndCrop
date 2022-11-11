//
//  View+Extensions.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/10/22.
//

import SwiftUI

extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}
