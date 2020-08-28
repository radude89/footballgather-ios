//
//  ConfirmPlayersModule.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class ConfirmPlayersModule {
    private var view: ConfirmPlayersViewProtocol
    private var router: ConfirmPlayersRouterProtocol
    private var interactor: ConfirmPlayersInteractorProtocol
    private var presenter: ConfirmPlayersPresenterProtocol
    
    init(view: ConfirmPlayersViewProtocol = ConfirmPlayersViewController(),
         router: ConfirmPlayersRouterProtocol = ConfirmPlayersRouter(),
         interactor: ConfirmPlayersInteractorProtocol = ConfirmPlayersInteractor(),
         presenter: ConfirmPlayersPresenterProtocol = ConfirmPlayersPresenter()) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension ConfirmPlayersModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        
        interactor.presenter = presenter
        
        view.interactor = interactor
        view.router = router
        
        return view as? UIViewController
    }
}
