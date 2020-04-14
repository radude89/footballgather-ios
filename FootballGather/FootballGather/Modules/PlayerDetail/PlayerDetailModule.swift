//
//  PlayerDetailModule.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerDetailModule {
    private var view: PlayerDetailViewProtocol
    private var router: PlayerDetailRouterProtocol
    private var interactor: PlayerDetailInteractorProtocol
    private var presenter: PlayerDetailPresenterProtocol
    
    init(view: PlayerDetailViewProtocol = PlayerDetailViewController(),
         router: PlayerDetailRouterProtocol = PlayerDetailRouter(),
         interactor: PlayerDetailInteractorProtocol,
         presenter: PlayerDetailPresenterProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension PlayerDetailModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        view.presenter = presenter
        
        return view as? UIViewController
    }
}
