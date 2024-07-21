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
    let images = AvatarsModel.models
    
    @Published var selectedImageIndex: [AvatarModel].Index
    
    var selectedImage: String {
        images[selectedImageIndex].imageName
    }
    
    @Published var age: Int = CharacterModel.ageAllowedRange.lowerBound
    @Published var height: Int = CharacterModel.heightAllowedRange.lowerBound
    @Published var weight: Int = CharacterModel.weightAllowedRange.lowerBound
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        self.selectedImageIndex = 0

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
                
                self.mapModel(characterModel: characterModel)

        }.store(in: &cancellables)
    }
    
    func mapModel(characterModel: CharacterModel) {
        self.age = characterModel.age
        self.height = characterModel.height
        self.weight = characterModel.weight
        
        if let imageIndex = self.images.firstIndex(of: characterModel.avatarModel) {
            self.selectedImageIndex = imageIndex
        }
    }
    
    func indexForModel(model: AvatarModel) -> Int? {
        return images.firstIndex(of: model)
    }
    
    func selectNextImage() {
        selectedImageIndex = min(selectedImageIndex + 1, images.count - 1)
    }
    
    func selectPrevImage() {
        selectedImageIndex = max(selectedImageIndex - 1, 0)
    }
    
    func sendAvatarToiPhone() {
        
        let characterModel = CharacterModel(avatarModel: images[selectedImageIndex],
                                            age: age, height: height, weight: weight)
        
        let message = MessageCoder().encodeMessage(type: characterModel)
        
        Task {
            do {
                try await service.sendMessageToCompanion(data: message)
            } catch let error {
                print(String(describing: error))
            }
        }
        
    }
}
