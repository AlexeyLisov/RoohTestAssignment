//
//  HorizontalPickerView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import SwiftUI


struct HorizontalPickerView: View {
    private let itemSize: CGFloat = 100
    
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(viewModel.images) { image in
                            Image(systemName: image.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: itemSize, height: itemSize)
                                .contentShape(Rectangle())
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.purple,
                                                lineWidth: viewModel.selectedImage == image.imageName ? 5 : 0)
                                )
                        }
                    }
                    .padding(2)
                }
                .scrollDisabled(true)
                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { value in
                        let horizontalAmount = value.translation.width
                        let verticalAmount = value.translation.height
                        
                        if abs(horizontalAmount) > abs(verticalAmount) {
                            
                            if horizontalAmount > 0 {
                                viewModel.selectPrevImage()
                            } else {
                                viewModel.selectNextImage()
                            }
                        }
                    })
                .contentMargins(.horizontal, 50, for: .scrollContent)
                .onAppear {
                    proxy.scrollTo(viewModel.selectedImage, anchor: .center)
                }
                .onChange(of: viewModel.selectedImage) { oldValue, newValue in
                    withAnimation {
                        proxy.scrollTo(viewModel.selectedImage, anchor: .center)
                    }
                }
            }
            controls
        }
        
    }
    
    var controls: some View {
        HStack {
            Image(systemName: "arrowshape.left.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .onTapGesture {
                    viewModel.selectPrevImage()
                }
                .padding(-2)
                .background(
                    Circle()
                        .foregroundStyle(.black)
                )
                
            
            Spacer()
            
            Image(systemName: "arrowshape.right.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .onTapGesture {
                    viewModel.selectNextImage()
                }
                .padding(-2)
                .background(
                    Circle()
                        .foregroundStyle(.black)
                )
        }.foregroundStyle(.white)
    }
    
}

#Preview {
    HorizontalPickerView(viewModel: MainViewModel())
}
