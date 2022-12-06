//
//  PhotoPickerView.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 10/27/22.
//

import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
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
                    Image(uiImage: displayImage!)
                        .resizable()
                        .scaledToFill()
                        .onTapGesture {
                            withoutAnimation {
                                displayPhotoCropper = true
                            }
                        }
                } else {
                    PhotoPicker(selectedItem: $selectedItem) {
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(screenSize.width * 0.25)
                            .foregroundColor(Color(UIColor.systemBackground))
                    }
                }
            }
            .frame(width: screenSize.width, height: screenSize.width, alignment: .center)
            
            Rectangle()
                .fill(Color(UIColor.systemBackground))
                .mask(circleMask.fill(style: FillStyle(eoFill: true)))
                .allowsHitTesting(false)
            
            VStack {
                if displayImage != nil {
                    Text("Tap image below to adjust zoom and crop.")
                        .padding(.top, screenSize.width * 0.3)
                }
                Spacer()
                PhotoPicker(selectedItem: $selectedItem) {
                    Label("Select a photo", systemImage: "photo")
                }
                .padding(.bottom, screenSize.width * 0.3)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $displayPhotoCropper) {
            PhotoCropper(profileImage: $profileImage)
        }
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

//MARK: - LOCAL COMPONENTS
extension PhotoPickerView {
    private var circleMask: Path {
        let inset: CGFloat = 15
        let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        let insetRect = CGRect(x: inset, y: inset, width: screenSize.width - (inset * 2), height: screenSize.height - (inset * 2))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
}

//MARK: - PHOTO PICKER
fileprivate struct PhotoPicker: View {
    @Binding var selectedItem: PhotosPickerItem?
    @ViewBuilder var label: any View
    
    var body: some View {
        ZStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    AnyView(label)
                }
                .foregroundColor(Color(UIColor.systemBackground))
                .tint(.purple)
                .buttonStyle(.borderedProminent)
        }
    }
}

//MARK: - PREVIEW
struct PhotoPicker_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPickerView(profileImage: .constant(ProfileImage()))
            .environment(\.screenSize, ViewSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
}
