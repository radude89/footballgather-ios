//
//  GatherModule.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class GatherModule {
    private var view: GatherViewProtocol
    private var router: GatherRouterProtocol
    private var interactor: GatherInteractorProtocol
    private var presenter: GatherPresenterProtocol
    
    init(view: GatherViewProtocol = GatherViewController(),
         router: GatherRouterProtocol = GatherRouter(),
         interactor: GatherInteractorProtocol,
         presenter: GatherPresenterProtocol) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension GatherModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        
        interactor.presenter = presenter
        
        view.interactor = interactor
        view.router = router
        
        return view as? UIViewController
    }
}
