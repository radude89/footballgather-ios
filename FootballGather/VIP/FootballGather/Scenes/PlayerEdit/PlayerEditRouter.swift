//
//  PlayerEditRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 22/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerEditRouter {
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension PlayerEditRouter: PlayerEditRouterProtocol {
    func dismissEditView() {
        navigationController.popViewController(animated: true)
    }
}
