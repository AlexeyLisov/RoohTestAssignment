//
//  MainViewModel.swift
//  RoohAvatarWatchOSApp Watch App
//
//  Created by Alexey Lisov on 19/07/2024.
//

import Foundation


class MainViewModel: ObservableObject {
    
    @Published var selectedImage: String = ""
    
    @Published var age: Int = 0
    @Published var height: Int = 0
    @Published var weight: Int = 0
    
    func sendAvatarToiPhone() {
        
    }
}
