//
//  GatherCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 23/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol GatherCoordinatorDelegate: AnyObject {
    func didEndGather()
}

final class GatherCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    weak var delegate: GatherCoordinatorDelegate?
    
    private let navController: UINavigationController
    private let gather: GatherModel
    
    init(navController: UINavigationController, parent: Coordinator? = nil, gather: GatherModel) {
        self.navController = navController
        self.parent = parent
        self.gather = gather
    }
    
    func start() {
        let viewController: GatherViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        viewController.gatherModel = gather
        navController.pushViewController(viewController, animated: true)
    }
    
    func didEndGather() {
        delegate?.didEndGather()
    }
    
}
