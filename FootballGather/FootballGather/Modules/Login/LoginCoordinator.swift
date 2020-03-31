//
//  LoginCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 19/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class LoginCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    private let navController: UINavigationController
    
    init(navController: UINavigationController, parent: Coordinator? = nil) {
        self.navController = navController
        self.parent = parent
    }
    
    func start() {
        let viewController: LoginViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        navController.pushViewController(viewController, animated: true)
    }
    
    func navigateToPlayerList() {
        let playerListCoordinator = PlayerListCoordinator(navController: navController, parent: self)
        playerListCoordinator.start()
        childCoordinators.append(playerListCoordinator)
    }
    
}
