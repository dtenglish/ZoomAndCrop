//
//  PhotoCropper.swift
//  ImageZoomAndCrop
//
//  Created by Daniel Taylor English on 11/10/22.
//

import SwiftUI

struct PhotoCropper: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.screenSize) var screenSize
    
    @Binding var profileImage: ProfileImage
    
    @State private var zoomScale: CGFloat = 1
    @State private var lastZoom: CGFloat = 1
    @State private var zoomAnchor: UnitPoint = .center
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    let inset: CGFloat = 15
    
    private var uiImage: UIImage {
        if let data = profileImage.imageData,
           let image = UIImage(data: data) {
            return image
        } else {
            return UIImage(systemName: "person.crop.circle")!
        }
    }
    
    private var originalScale: CGFloat {
        if uiImage.size.width / uiImage.size.height >= screenSize.width / screenSize.height {
            return screenSize.width / uiImage.size.width
        } else {
            return screenSize.height / uiImage.size.height
        }
    }
    
    var body: some View {
        ZStack {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .position(x: screenSize.width / 2,
                          y: screenSize.height / 2)
                .scaleEffect(zoomScale, anchor: zoomAnchor)
                .offset(offset)
            
            Rectangle()
                .fill(Color.black)
                .opacity(0.55)
                .mask(circleMask.fill(style: FillStyle(eoFill: true)))
            
            VStack {
                Spacer()
                HStack() {
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
        .gesture(zoomGesture)
        .simultaneousGesture(panGesture)
        .background(Color.black)
    }
}

//MARK: - FUNCTIONS
extension PhotoCropper {
    func saveImage() {
        //        profileImage.scale = Double(zoomScale)
        //        profileImage.position = finalPosition
        guard let croppedImage = cropImage(uiImage) else {
            return
        }
        print("photo cropped")
        print(croppedImage.size)
        profileImage.croppedImageData = croppedImage.pngData()
    }
    
    func cropImage(_ image: UIImage) -> UIImage? {
        guard let cgImage: CGImage = image.cgImage else {
            print("failed to convert to CGImage")
            return nil
        }
        
        let imageWidth: CGFloat = CGFloat(cgImage.width)
        let imageHeight: CGFloat = CGFloat(cgImage.height)
        let scaler: CGFloat = imageWidth / screenSize.width
        
        var cropRect: CGRect {
//            let imageWidth: CGFloat = uiImage.size.width.pixelsToPoints()
//            let imageHeight: CGFloat = uiImage.size.height.pixelsToPoints()
//
//            let cropSize: CGFloat = (screenSize.width / originalScale)
            
            let cropSize: CGFloat = (screenSize.width * scaler) / zoomScale
//            let cropSize: CGFloat = ((screenSize.width - (inset * 2)) * scaler)
            
            // intial offsets good!!
            let initialX: CGFloat = ((imageWidth - cropSize) / 2)
            let initialY: CGFloat = ((imageHeight - cropSize) / 2)

            // below: scaling + zoom good! panning not working
//            let xOffset: CGFloat = ((initialX + (offset.width * scaler)) * zoomScale)
//            let yOffset: CGFloat = ((initialY + (offset.height * scaler)) * zoomScale)
            
            let xOffset: CGFloat = initialX - (offset.width * scaler) / zoomScale
            let yOffset: CGFloat = initialY - (offset.height * scaler) / zoomScale
            
            let rect = CGRect(x: xOffset, y: yOffset, width: cropSize, height: cropSize)
//            print("scaler: \(scaler)")
//            print("zoom scale: \(zoomScale)")
//            print("crop size: \(cropSize)")
//            print("image dims: \(imageWidth), \(imageHeight)")
//            print("offset \(offset)")
//            print("cropRect: \(rect)")
            return rect
        }
        
        guard let croppedImage = cgImage.cropping(to: cropRect) else {
            print("failed to crop image")
            return nil
        }
        //            profileImage.croppedImageData = UIImage(cgImage: croppedImage).pngData()
        return UIImage(cgImage: croppedImage)
    }
    
    private func setOffsetAndScale() {
        let newZoom: CGFloat = .minimum(.maximum(zoomScale, 1), 4)
        
        let imageWidth = (uiImage.size.width * originalScale) * newZoom
        let imageHeight = (uiImage.size.height * originalScale) * newZoom
        var width: CGFloat = .zero
        var height: CGFloat = .zero
        
        if imageWidth > screenSize.width {
            let widthLimit: CGFloat = imageWidth > screenSize.width ?
            (imageWidth - screenSize.width) / 2
            : 0
            
            width = offset.width > 0 ?
                .minimum(widthLimit, offset.width) :
                .maximum(-widthLimit, offset.width)
        }
        
        if imageHeight > screenSize.height {
            let heightLimit: CGFloat = imageHeight > screenSize.height ?
            (imageHeight - screenSize.height) / 2
            : 0
            
            height = offset.height > 0 ?
                .minimum(heightLimit, offset.height) :
                .maximum(-heightLimit, offset.height)
        }
        
        let newOffset = CGSize(width: width, height: height)
        
        lastZoom = newZoom
        lastOffset = newOffset
        
        withAnimation() {
            offset = newOffset
            zoomScale = newZoom
        }
    }
}

//MARK: - GESTURES
extension PhotoCropper {
    var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { gesture in
                zoomAnchor = .center
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
        let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        let insetRect = CGRect(x: inset, y: inset, width: screenSize.width - (inset * 2), height: screenSize.height - (inset * 2))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }
    
    private var cancelButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Cancel")
        }
    }
    
    private var saveButton: some View {
        Button {
            saveImage()
            dismiss()
        } label: {
            Text("Save")
        }
    }
}

struct PhotoCropper_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCropper(profileImage: .constant(ProfileImage(scale: 1, position: .zero)))
            .environment(\.screenSize, CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    }
}
