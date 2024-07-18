//
//  Coordinator.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 18/07/2024.
//

import Foundation
import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}
