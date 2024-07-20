//
//  MainViewModel.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import Foundation


class MainViewModel: ObservableObject {
    
    let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
    
    var selectedImageIndex: [AvatarModel].Index
    @Published var selectedImage: String = ""
    
    init() {
        self.selectedImageIndex = 0
        self.selectedImage = images[self.selectedImageIndex].imageName
    }
    
    @Published var age: Int = 0
    @Published var height: Int = 0
    @Published var weight: Int = 0
    
    func selectNextImage() {
        selectedImageIndex = min(selectedImageIndex + 1, images.endIndex - 1)
        self.selectedImage = images[self.selectedImageIndex].imageName
    }
    
    func selectPrevImage() {
        selectedImageIndex = max(selectedImageIndex - 1, images.startIndex)
        self.selectedImage = images[self.selectedImageIndex].imageName
    }
    
    func sendAvatarToiPhone() {
        
    }
}
