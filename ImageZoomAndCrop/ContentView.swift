//
//  ContentView.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/3/22.
//

import SwiftUI

struct ContentView: View {
    @State var profileImage = ProfileImage()
    
    var body: some View {
        VStack {
            PhotoPicker(profileImage: $profileImage)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
