//
//  MainViewModel.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import Foundation
import Combine

class MainViewModel: ObservableObject {
    
    let service = WatchConnectivityService()
    let images = ["circle", "square", "square.and.arrow.up", "pencil", "eraser"].map { AvatarModel(imageName: $0) }
    
    var selectedImageIndex: [AvatarModel].Index
    @Published var selectedImage: String = ""
    
    var cancellables = Set<AnyCancellable>()
    init() {
        self.selectedImageIndex = 0
        self.selectedImage = images[self.selectedImageIndex].imageName
        
        
        service.setupWCSession()
        Task {
            await service.activateSession()
        }
        
        service.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
            guard let characterModel = MessageCoder().decodeMessage(message: message) else {
                fatalError("can't decode characterModel")
            }
            
            self.age = characterModel.age
            self.height = characterModel.height
            self.weight = characterModel.weight
        }.store(in: &cancellables)
            
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
        
        let characterModel = CharacterModel(avatarModel: images[selectedImageIndex],
                                            age: age, height: height, weight: weight)
        
        let message = MessageCoder().encodeMessage(type: characterModel)
        
        Task {
            do {
                try await service.sendMessageToWatch(data: message)
            } catch let error {
                print(String(describing: error))
            }
        }
        
    }
}
