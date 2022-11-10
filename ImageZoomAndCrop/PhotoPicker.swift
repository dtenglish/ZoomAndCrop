//
//  PhotoPicker.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 10/27/22.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @Environment(\.screenSize) var screenSize
    @Binding var profileImage: ProfileImage
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var displayPhotoCropper = false
    
    var imageConstraint: Double {
        let width = screenSize.width - 30
        return width
    }
    
    var displayImage: UIImage? {
        if let data = profileImage.croppedImageData,
           let image = UIImage(data: data) {
            return image
        } else if let data = profileImage.imageData,
                  let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                if displayImage != nil {
                    Button {
                        displayPhotoCropper = true
                    } label : {
                        Image(uiImage: displayImage!)
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: imageConstraint, height: imageConstraint, alignment: .center)
                    }
                    
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(UIColor.systemBackground))
                }
            }
            .padding(screenSize.width * 0.15)
            .frame(width: imageConstraint, height: imageConstraint, alignment: .center)
            .background(.purple)
//            .clipShape(Circle())
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Label("Select a photo", systemImage: "photo")
                }
                .padding(.top)
                .foregroundColor(Color(UIColor.systemBackground))
                .tint(.purple)
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            profileImage.imageData = data
                            profileImage.croppedImageData = nil
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $displayPhotoCropper) {
            PhotoCropper(profileImage: $profileImage)
        }
    }
}

//struct PhotoPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        PhotoPicker(imageData: .constant(Data()))
//            .environment(\.screenSize, CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//    }
//}
