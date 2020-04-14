//
//  LoginModule.swift
//  FootballGather
//
//  Created by Radu Dan on 13/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class LoginModule {
    
    private var view: LoginViewProtocol
    private var router: LoginRouterProtocol
    private var interactor: LoginInteractorProtocol
    private var presenter: LoginPresenterProtocol
        
    init(view: LoginViewProtocol = LoginViewController(),
         router: LoginRouterProtocol = LoginRouter(),
         interactor: LoginInteractorProtocol = LoginInteractor(),
         presenter: LoginPresenterProtocol = LoginPresenter()) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.presenter = presenter
    }
    
}

extension LoginModule: AppModule {
    func assemble() -> UIViewController? {
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        
        interactor.presenter = presenter
        
        view.presenter = presenter
        
        return view as? UIViewController
    }
}
