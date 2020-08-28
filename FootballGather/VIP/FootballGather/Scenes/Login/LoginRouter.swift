//
//  LoginRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 13/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class LoginRouter {
    
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension LoginRouter: LoginRouterProtocol {
    func showPlayerList() {
        let module = moduleFactory.makePlayerList(using: navigationController)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}
