//
//  AvatarCollectionViewModel.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 19/07/2024.
//

import UIKit
import Combine

class AvatarCollectionViewModel {
    
    private var images: [AvatarModel]
    @Published private(set) var selectedIndexPath: IndexPath
    
    var avatarModel: AvatarModel {
        images[selectedIndexPath.item]
    }
    
    init(images: [AvatarModel]) {
        self.images = images
        self.selectedIndexPath = IndexPath(item: 0, section: 0)
    }
    
    func numberOfItems() -> Int {
        return images.count
    }
    
    func image(for indexPath: IndexPath) -> UIImage? {
        let imageName = images[indexPath.item].imageName
        return UIImage(named: imageName)
    }
    
    func selectItem(at indexPath: IndexPath) {
        selectedIndexPath = indexPath
    }
    
    func isSelectedItem(at indexPath: IndexPath) -> Bool {
        return selectedIndexPath == indexPath
    }
    
    func selectItem(with model: AvatarModel) {
        guard let index = images.firstIndex(of: model) else {
            return
        }
        
        selectItem(at: IndexPath(item: index, section: 0))
    }
}

extension AvatarCollectionViewModel {
    static var mock: AvatarCollectionViewModel = {
        let images = AvatarsModel.models
        return AvatarCollectionViewModel(images: images)
    }()
}
