//
//  PlayerAddCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 20/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol PlayerAddCoordinatorDelegate: AnyObject {
    func playerWasAdded()
}

final class PlayerAddCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    weak var delegate: PlayerAddCoordinatorDelegate?
    
    private let navController: UINavigationController
    
    init(navController: UINavigationController, parent: Coordinator? = nil) {
        self.navController = navController
        self.parent = parent
    }
    
    func start() {
        let viewController: PlayerAddViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        navController.pushViewController(viewController, animated: true)
    }
    
    func playerWasAdded() {
        delegate?.playerWasAdded()
        navController.popViewController(animated: true)
    }

}
