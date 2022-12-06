//
//  ContentView.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 11/3/22.
//

import SwiftUI

struct ContentView: View {
    @State var profileImage = ProfileImage()
    
    var body: some View {
        VStack {
            PhotoPickerView(profileImage: $profileImage)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
