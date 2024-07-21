//
//  CharacterModel.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 21/07/2024.
//

import Foundation

struct CharacterModel: Codable {
    var avatarModel: AvatarModel
    var age: Int
    var height: Int
    var weight: Int
}

extension CharacterModel {
    static var ageAllowedRange: ClosedRange<Int> {
        return 0...150
    }
    
    static var heightAllowedRange: ClosedRange<Int> {
        return 50...220
    }
    
    static var weightAllowedRange: ClosedRange<Int> {
        return 40...500
    }
}
