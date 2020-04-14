//
//  PlayerEditModule.swift
//  FootballGather
//
//  Created by Radu Dan on 22/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerEditModule {
    private var view: PlayerEditViewProtocol
    private var router: PlayerEditRouterProtocol
    private var interactor: PlayerEditInteractorProtocol
    private var presenter: PlayerEditPresenterProtocol
    
    init(view: PlayerEditViewProtocol = PlayerEditViewController(),
         router: PlayerEditRouterProtocol = PlayerEditRouter(),
         interactor: PlayerEditInteractorProtocol,
         presenter: PlayerEditPresenterProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension PlayerEditModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        view.presenter = presenter
        
        return view as? UIViewController
    }
}
