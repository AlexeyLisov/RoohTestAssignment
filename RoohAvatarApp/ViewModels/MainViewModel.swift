//
//  MainViewModel.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 21/07/2024.
//

import Combine
import WatchConnectivity


class MainViewModel: ObservableObject {
    @Published var age: Int = CharacterModel.ageAllowedRange.lowerBound
    @Published var height: Int = CharacterModel.heightAllowedRange.lowerBound
    @Published var weight: Int = CharacterModel.weightAllowedRange.lowerBound
    
    @Published var sendingMessageStatus: SendingMessageStatus = .notRequested
    
    var avatarCollectionViewModel: AvatarCollectionViewModel
    
    let watchService: WatchConnectivityServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    func setInitialValues() {
        age = CharacterModel.ageAllowedRange.lowerBound
        height = CharacterModel.heightAllowedRange.lowerBound
        weight = CharacterModel.weightAllowedRange.lowerBound
    }
    
    
    init(watchService: WatchConnectivityService = WatchConnectivityService()) {
        self.watchService = watchService
        self.avatarCollectionViewModel = AvatarCollectionViewModel(images: AvatarsModel.models)
        
        self.watchService.setupWCSession()
        
        // TODO: check reference cycle
        self.watchService.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { message in
            
            guard let characterModel = MessageCoder().decodeMessage(message: message) else {
                return
            }
            
            self.mapModel(characterModel: characterModel)
        }
        .store(in: &cancellables)
    }
    
    func sendAvatarToAppleWatch() {
        
        sendingMessageStatus = .creatingSession
        guard self.watchService.setupWCSession() else {
            sendingMessageStatus = .error(.init(.sessionNotSupported))
            sendingMessageStatus = .notRequested
            return
        }
        
        let characterModel = CharacterModel(avatarModel: avatarCollectionViewModel.avatarModel,
                                            age: age, height: height, weight: weight)
        
        let encodedMessage = MessageCoder().encodeMessage(type: characterModel)
        
        Task {
            await self.watchService.activateSession()
            
            await MainActor.run {
                sendingMessageStatus = .sendingMessage
            }
            
            do {
                try await self.watchService.sendMessageToCompanion(data: encodedMessage)
            } catch let error as WCError {
                sendingMessageStatus = .error(error)
                return
            }
            
            await MainActor.run {
                sendingMessageStatus = .success
            }
        }
    }
    
    func mapModel(characterModel: CharacterModel) {
        self.age = characterModel.age
        self.height = characterModel.height
        self.weight = characterModel.weight
        self.avatarCollectionViewModel.selectItem(with: characterModel.avatarModel)
    }
    
}
