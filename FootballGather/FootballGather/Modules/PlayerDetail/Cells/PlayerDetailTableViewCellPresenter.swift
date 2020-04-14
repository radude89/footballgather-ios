//
//  PlayerDetailTableViewCellPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct PlayerDetailTableViewCellPresenter: PlayerDetailTableViewCellPresenterProtocol {
    var view: PlayerDetailTableViewCellProtocol?
    
    init(view: PlayerDetailTableViewCellProtocol? = nil) {
        self.view = view
    }
    
    func configure(with rowDetail: PlayerDetailRow) {
        view?.setLeftLabelText(rowDetail.title)
        view?.setRightLabelText(rowDetail.value)
    }
}
