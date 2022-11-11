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
        ZStack {
            ZStack {
                if displayImage != nil {
                    Button {
                        withoutAnimation {
                            displayPhotoCropper = true
                        }
                    } label: {
                        Image(uiImage: displayImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    
                } else {
                    ZStack {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(screenSize.width * 0.25)
                            .foregroundColor(Color(UIColor.systemBackground))
                    }
                    .background(.purple)
                }
            }
            .frame(width: screenSize.width, height: screenSize.width, alignment: .center)
            
            Rectangle()
                .fill(Color.black)
                .mask(circleMask.fill(style: FillStyle(eoFill: true)))
                .allowsHitTesting(false)
            
            VStack {
                Spacer()
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()) {
                        Label("Select a photo", systemImage: "photo")
                    }
                    .padding(.bottom, screenSize.width * 0.3)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $displayPhotoCropper) {
            PhotoCropper(profileImage: $profileImage)
        }
    }
}

//MARK: - LOCAL COMPONENTS
extension PhotoPicker {
    private var circleMask: Path {
        let inset: CGFloat = 15
        let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        let insetRect = CGRect(x: inset, y: inset, width: screenSize.width - (inset * 2), height: screenSize.height - (inset * 2))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
}

struct PhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPicker(profileImage: .constant(ProfileImage()))
            .environment(\.screenSize, CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
}
