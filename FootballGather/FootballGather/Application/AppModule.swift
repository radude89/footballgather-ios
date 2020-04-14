//
//  AppModule.swift
//  FootballGather
//
//  Created by Radu Dan on 20/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol AppModule {
    func assemble() -> UIViewController?
}

protocol ModuleFactoryProtocol {
    func makeLogin(using navigationController: UINavigationController) -> LoginModule
    func makePlayerList(using navigationController: UINavigationController) -> PlayerListModule
    func makePlayerDetails(using navigationController: UINavigationController,
                           for player: PlayerResponseModel,
                           delegate: PlayerDetailDelegate) -> PlayerDetailModule
    func makePlayerEdit(using navigationController: UINavigationController,
                        for playerEditable: PlayerEditable,
                        delegate: PlayerEditDelegate) -> PlayerEditModule
    func makePlayerAdd(using navigationController: UINavigationController, delegate: PlayerAddDelegate) -> PlayerAddModule
    func makeConfirmPlayers(using navigationController: UINavigationController,
                            playersDictionary: [TeamSection: [PlayerResponseModel]],
                            delegate: ConfirmPlayersDelegate) -> ConfirmPlayersModule
    func makeGather(using navigationController: UINavigationController,
                    gather: GatherModel,
                    delegate: GatherDelegate) -> GatherModule
}

struct ModuleFactory: ModuleFactoryProtocol {
    func makeLogin(using navigationController: UINavigationController = UINavigationController()) -> LoginModule {
        let router = LoginRouter(navigationController: navigationController, moduleFactory: self)
        let view: LoginViewController = Storyboard.defaultStoryboard.instantiateViewController()
        return LoginModule(view: view, router: router)
    }
    
    func makePlayerList(using navigationController: UINavigationController = UINavigationController()) -> PlayerListModule {
        let router = PlayerListRouter(navigationController: navigationController, moduleFactory: self)
        let view: PlayerListViewController = Storyboard.defaultStoryboard.instantiateViewController()
        return PlayerListModule(view: view, router: router)
    }
    
    func makePlayerDetails(using navigationController: UINavigationController = UINavigationController(),
                           for player: PlayerResponseModel,
                           delegate: PlayerDetailDelegate) -> PlayerDetailModule {
        let router = PlayerDetailRouter(navigationController: navigationController, moduleFactory: self)
        let view: PlayerDetailViewController = Storyboard.defaultStoryboard.instantiateViewController()
        let interactor = PlayerDetailInteractor(player: player)
        let presenter = PlayerDetailPresenter(interactor: interactor, delegate: delegate)
        
        return PlayerDetailModule(view: view, router: router, interactor: interactor, presenter: presenter)
    }
    
    func makePlayerEdit(using navigationController: UINavigationController = UINavigationController(),
                        for playerEditable: PlayerEditable,
                        delegate: PlayerEditDelegate) -> PlayerEditModule {
        let router = PlayerEditRouter(navigationController: navigationController, moduleFactory: self)
        let view: PlayerEditViewController = Storyboard.defaultStoryboard.instantiateViewController()
        let interactor = PlayerEditInteractor(playerEditable: playerEditable)
        let presenter = PlayerEditPresenter(interactor: interactor, delegate: delegate)
        
        return PlayerEditModule(view: view, router: router, interactor: interactor, presenter: presenter)
    }
    
    func makePlayerAdd(using navigationController: UINavigationController = UINavigationController(),
                       delegate: PlayerAddDelegate) -> PlayerAddModule {
        let router = PlayerAddRouter(navigationController: navigationController, moduleFactory: self)
        let view: PlayerAddViewController = Storyboard.defaultStoryboard.instantiateViewController()
        let presenter = PlayerAddPresenter(delegate: delegate)
        
        return PlayerAddModule(view: view, router: router, presenter: presenter)
    }
    
    func makeConfirmPlayers(using navigationController: UINavigationController = UINavigationController(),
                            playersDictionary: [TeamSection: [PlayerResponseModel]],
                            delegate: ConfirmPlayersDelegate) -> ConfirmPlayersModule {
        let router = ConfirmPlayersRouter(navigationController: navigationController, moduleFactory: self)
        let view: ConfirmPlayersViewController = Storyboard.defaultStoryboard.instantiateViewController()
        let interactor = ConfirmPlayersInteractor(playersDictionary: playersDictionary)
        let presenter = ConfirmPlayersPresenter(delegate: delegate)
        
        return ConfirmPlayersModule(view: view, router: router, interactor: interactor, presenter: presenter)
    }
    
    func makeGather(using navigationController: UINavigationController,
                    gather: GatherModel,
                    delegate: GatherDelegate) -> GatherModule {
        let router = GatherRouter(navigationController: navigationController, moduleFactory: self)
        let view: GatherViewController = Storyboard.defaultStoryboard.instantiateViewController()
        let interactor = GatherInteractor(gather: gather)
        let presenter = GatherPresenter(interactor: interactor, delegate: delegate)
        
        return GatherModule(view: view, router: router, interactor: interactor, presenter: presenter)
    }
}
