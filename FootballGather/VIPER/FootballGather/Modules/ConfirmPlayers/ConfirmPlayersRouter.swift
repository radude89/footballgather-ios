//
//  ConfirmPlayersRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class ConfirmPlayersRouter {
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension ConfirmPlayersRouter: ConfirmPlayersRouterProtocol {
    func showGatherView(for gather: GatherModel, delegate: GatherDelegate) {
        let module = moduleFactory.makeGather(using: navigationController, gather: gather, delegate: delegate)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
