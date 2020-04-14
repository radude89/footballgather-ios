//
//  PlayerAddModule.swift
//  FootballGather
//
//  Created by Radu Dan on 24/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerAddModule {
    private var view: PlayerAddViewProtocol
    private var router: PlayerAddRouterProtocol
    private var interactor: PlayerAddInteractorProtocol
    private var presenter: PlayerAddPresenterProtocol
    
    init(view: PlayerAddViewProtocol = PlayerAddViewController(),
         router: PlayerAddRouterProtocol = PlayerAddRouter(),
         interactor: PlayerAddInteractorProtocol = PlayerAddInteractor(),
         presenter: PlayerAddPresenterProtocol = PlayerAddPresenter()) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension PlayerAddModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        view.presenter = presenter
        
        return view as? UIViewController
    }
}
