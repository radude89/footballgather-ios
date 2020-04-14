//
//  ConfirmPlayersTableViewCellPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct ConfirmPlayersTableViewCellPresenter: ConfirmPlayersTableViewCellPresenterProtocol {
    var view: ConfirmPlayersTableViewCellProtocol?
    
    init(view: ConfirmPlayersTableViewCellProtocol? = nil) {
        self.view = view
    }
    
    func configure(title: String?, descriptionDetails: String?) {
        view?.setTextLabel(title)
        view?.setDetailLabel(descriptionDetails)
    }
}
