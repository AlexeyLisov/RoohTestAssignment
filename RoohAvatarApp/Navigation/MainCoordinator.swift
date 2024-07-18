//
//  MainCoordinator.swift
//  RoohAvatarApp
//
//  Created by Alexey Lisov on 18/07/2024.
//

import Foundation
import UIKit


class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = ViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
}
