//
//  AvatarModel.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import Foundation


struct AvatarModel: Identifiable, Hashable {
    var id: String {
        return imageName
    }
    
    let imageName: String
}
