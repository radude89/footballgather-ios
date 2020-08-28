//
//  PlayerAddRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerAddRouter {
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension PlayerAddRouter: PlayerAddRouterProtocol {
    func dismissAddView() {
        navigationController.popViewController(animated: true)
    }
}
