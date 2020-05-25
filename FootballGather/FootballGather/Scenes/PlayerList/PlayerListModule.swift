//
//  PlayerListModule.swift
//  FootballGather
//
//  Created by Radu Dan on 15/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerListModule {
    
    private var view: PlayerListViewProtocol
    private var router: PlayerListRouterProtocol
    private var interactor: PlayerListInteractorProtocol
    private var presenter: PlayerListPresenterProtocol
    
    init(view: PlayerListViewProtocol = PlayerListViewController(),
         router: PlayerListRouterProtocol = PlayerListRouter(),
         interactor: PlayerListInteractorProtocol = PlayerListInteractor(),
         presenter: PlayerListPresenterProtocol = PlayerListPresenter()) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension PlayerListModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        
        interactor.presenter = presenter
        
        view.interactor = interactor
        view.router = router
        
        return view as? UIViewController
    }
}
