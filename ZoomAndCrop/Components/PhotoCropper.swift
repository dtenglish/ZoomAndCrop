//
//  PhotoCropper.swift
//  ZoomAndCrop
//
//  Created by Daniel Taylor English on 11/10/22.
//

import SwiftUI

// TODO: Fix - Images sometimes shift a few pixels when cropping, slightly more noticeable on zoomed in landscape images.
// TODO: Adjust zoom to anchor to center of current view rather than center of image
struct PhotoCropper: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.screenSize) var screenSize
    
    @Binding var profileImage: ProfileImage
    
    @State private var zoomScale: CGFloat = 1
    @State private var lastZoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    private var uiImage: UIImage {
        if let data = profileImage.imageData,
           let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(systemName: "person.crop.circle")!
        }
    }
    
    private var imageScale: CGFloat {
        if uiImage.shortSide / uiImage.longSide >= screenSize.shortSide / screenSize.longSide {
            return screenSize.shortSide / uiImage.shortSide
        } else {
            return screenSize.longSide / uiImage.longSide
        }
    }
    
    private var imageConstraint: CGFloat {
        return screenSize.shortSide
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: imageConstraint, height: imageConstraint)
                .position(x: screenSize.width / 2,
                          y: screenSize.height / 2)
                .scaleEffect(zoomScale)
                .offset(offset)
                .gesture(panGesture.simultaneously(with: zoomGesture))
                .onAppear {
                    loadPreviousValues()
                }
            
            Rectangle()
                .fill(Color.black)
                .opacity(0.75)
                .mask(circleMask.fill(style: FillStyle(eoFill: true)))
                .allowsHitTesting(false)
            
            VStack {
                Spacer()
                HStack {
                    cancelButton
                    Spacer()
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            }
        }
        .ignoresSafeArea()
        .background(Color.black)
    }
}

//MARK: - FUNCTIONS
extension PhotoCropper {
    func saveImage() {
        guard let croppedImage = cropImage(uiImage) else {
            return
        }
        print("photo cropped successfully")
        profileImage.croppedImageData = croppedImage.pngData()
        profileImage.scale = Double(zoomScale)
        profileImage.position = offset
    }
    
    func cropImage(_ image: UIImage) -> UIImage? {
        guard let cgImage: CGImage = image.fixOrientation().cgImage else {
            print("failed to convert to CGImage")
            return nil
        }
        
        let imageWidth: CGFloat = CGFloat(cgImage.width)
        let imageHeight: CGFloat = CGFloat(cgImage.height)
        
        var cropRect: CGRect {
            let cropSize: CGFloat = (imageConstraint / imageScale) / zoomScale
            let initialX: CGFloat = (imageWidth - cropSize) / 2
            let initialY: CGFloat = (imageHeight - cropSize) / 2
            let xOffset: CGFloat = initialX - (offset.width / imageScale) / zoomScale
            let yOffset: CGFloat = initialY - (offset.height / imageScale) / zoomScale
            let rect = CGRect(x: xOffset, y: yOffset, width: cropSize, height: cropSize)
            return rect
        }
        
        guard let croppedImage = cgImage.cropping(to: cropRect) else {
            print("failed to crop image")
            return nil
        }
        
        return UIImage(cgImage: croppedImage)
    }
    
    private func setOffsetAndScale() {
        let newZoom: CGFloat = min(max(zoomScale, 1), 4)
        let imageWidth = (uiImage.size.width * imageScale) * newZoom
        let imageHeight = (uiImage.size.height * imageScale) * newZoom
        
        var width: CGFloat {
            if imageWidth > imageConstraint {
                let widthLimit: CGFloat = (imageWidth - imageConstraint) / 2
                
                if offset.width > 0 {
                    return min(widthLimit, offset.width)
                } else {
                    return max(-widthLimit, offset.width)
                }
            } else {
                return .zero
            }
        }
        
        var height: CGFloat {
            if imageHeight > imageConstraint {
                let heightLimit: CGFloat = (imageHeight - imageConstraint) / 2
                
                if offset.height > 0 {
                    return min(heightLimit, offset.height)
                } else {
                    return max(-heightLimit, offset.height)
                }
            } else {
                return .zero
            }
        }
        
        let newOffset = CGSize(width: width, height: height)
        
        lastOffset = newOffset
        lastZoom = newZoom
        
        withAnimation() {
            offset = newOffset
            zoomScale = newZoom
        }
    }
    
    func loadPreviousValues() {
        if profileImage.croppedImageData != nil {
            if profileImage.position != .zero {
                offset = profileImage.position
                lastOffset = profileImage.position
            }
            
            if profileImage.scale != 0 {
                zoomScale = profileImage.scale
                lastZoom = profileImage.scale
            }
        }
    }
}

//MARK: - GESTURES
extension PhotoCropper {
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { gesture in
                zoomScale = lastZoom * gesture
            }
            .onEnded { _ in
                setOffsetAndScale()
            }
    }
    
    var panGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                var newOffset = lastOffset
                newOffset.width += gesture.translation.width
                newOffset.height += gesture.translation.height
                offset = newOffset
            }
            .onEnded { _ in
                setOffsetAndScale()
            }
    }
}

//MARK: - LOCAL COMPONENTS
extension PhotoCropper {
    private var circleMask: Path {
        let inset: CGFloat = 15
        let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        let insetRect = CGRect(x: inset, y: inset, width: screenSize.width - (inset * 2), height: screenSize.height - (inset * 2))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
    
    private var cancelButton: some View {
        Button {
            withoutAnimation {
                dismiss()
            }
        } label: {
            Text("Cancel")
        }
    }
    
    private var saveButton: some View {
        Button {
            saveImage()
            withoutAnimation {
                dismiss()
            }
        } label: {
            Text("Save")
        }
    }
}

//MARK: - PREVIEW
struct PhotoCropper_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCropper(profileImage: .constant(ProfileImage(scale: 1, position: .zero)))
            .environment(\.screenSize, ViewSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
}
