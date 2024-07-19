//
//  ContentView.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 18/07/2024.
//

import SwiftUI
import UIKit

struct AvatarModel: Identifiable {
    var id: String {
        return imageName
    }
    
    let imageName: String
}


class MainViewModel: ObservableObject {
    
    @Published var selectedImage: String = ""
    
    @Published var age: Int = 0
    @Published var height: Int = 0
    @Published var weight: Int = 0
    
    func sendAvatarToiPhone() {
        
    }
}

struct MainView: View {
    
    let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
    @ObservedObject var viewModel = MainViewModel()
    
//    init(viewModel: MainViewModel = MainViewModel(), offset: Double = CGFloat.zero) {
//        self.viewModel = viewModel
//        self.offset = offset
//        
//        self.offset.si
//    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    imagesScrollView
                }
                
                VStack {
                    agePicker
                    heightPicker
                    weightPicker
                }
                .labelsHidden()
                
                Button("Send to iPhone") {
                    viewModel.sendAvatarToiPhone()
                }
            }
        }
    }
    
    var agePicker: some View {
        VStack {
            Text("Age")
                .bold()
            Picker("Age", selection: $viewModel.age) {
                ForEach(0..<125) {
                    Text("\($0)")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var heightPicker: some View {
        VStack {
            Text("Height")
                .bold()
            Picker("Height", selection: $viewModel.height) {
                ForEach(50..<250) {
                    Text("\($0) cm")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var weightPicker: some View {
        VStack {
            Text("Weight")
                .bold()
            
            Picker("Weight", selection: $viewModel.weight) {
                ForEach(50..<300) {
                    Text("\($0) kg")
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 50)
        }
    }
    
    var imagesScrollView: some View {

        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                ZStack{
                    LazyHStack {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            
                            Image(systemName: image.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: itemSize, height: itemSize)
                                .contentShape(Rectangle())
                                .gesture(TapGesture().onEnded {
                                    viewModel.selectedImage = image.imageName
                                    withAnimation {
                                        proxy.scrollTo(index, anchor: .center)
                                    }
                                })
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.purple, lineWidth: viewModel.selectedImage == image.imageName ? 5 : 0)
                                )
                        }
                        
                    }
                    .padding(2)
                }
            }
            .coordinateSpace(name: "scroll")
        }
    }
    
    private let itemSize: CGFloat = 100
}




struct ContentView: View {
    var body: some View {
        VStack {
            MainView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
