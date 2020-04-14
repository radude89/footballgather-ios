//
//  GatherRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class GatherRouter {
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension GatherRouter: GatherRouterProtocol {
    func popToPlayerListView() {
        guard let viewController = navigationController.viewControllers.first(where: { $0 is PlayerListViewController }) else {
            return
        }
        
        navigationController.popToViewController(viewController, animated: true)
    }
}
