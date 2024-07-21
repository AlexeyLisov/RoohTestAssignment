//
//  MessageCoder.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 21/07/2024.
//

import Foundation


//protocol MessageCoder {
//    func encodeMessage(type: CharacterModel) -> [String: Any]
//    func decodeMessage(message: [String: Any]) -> CharacterModel?
//}

struct MessageCoder {
    
    private enum Keys: String {
        case characterModel
    }
    
    func encodeMessage(type: CharacterModel) -> [String: Any] {
        
        guard let encodedData = try? JSONEncoder().encode(type) else {
            return [:]
        }
        
        return [Keys.characterModel.rawValue: encodedData]
        
    }
    
    func decodeMessage(message: [String: Any]) -> CharacterModel? {
        
        guard let encodedModelData = message[Keys.characterModel.rawValue] as? Data else {
            return nil
        }
        
        guard let decodedCharacterModel = try? JSONDecoder().decode(CharacterModel.self, from: encodedModelData) else {
            return nil
        }
        
        return decodedCharacterModel
    }
}
