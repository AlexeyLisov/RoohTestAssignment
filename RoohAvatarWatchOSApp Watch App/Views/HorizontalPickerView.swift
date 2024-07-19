//
//  HorizontalPickerView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI


struct HorizontalPickerView: View {
    private let itemSize: CGFloat = 100
    
    let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(images) { image in
                        
                        Image(systemName: image.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: itemSize, height: itemSize)
                            .contentShape(Rectangle())
                            .gesture(TapGesture().onEnded {
                                viewModel.selectedImage = image.imageName
                                withAnimation {
                                    proxy.scrollTo(image, anchor: .center)
                                }
                            })
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.purple,
                                            lineWidth: viewModel.selectedImage == image.imageName ? 5 : 0)
                            )
                    }
                    
                }
                .padding(2)
            }
        }
    }
    
}

#Preview {
    HorizontalPickerView(viewModel: MainViewModel())
}
