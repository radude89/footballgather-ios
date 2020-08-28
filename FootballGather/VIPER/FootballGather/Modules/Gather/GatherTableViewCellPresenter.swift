//
//  GatherTableViewCellPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

struct GatherTableViewCellPresenter: GatherTableViewCellPresenterProtocol {
    var view: GatherTableViewCellProtocol?
    
    init(view: GatherTableViewCellProtocol? = nil) {
        self.view = view
    }
    
    func configure(title: String, descriptionDetails: String?) {
        view?.setTextLabel(title)
        view?.setDetailLabel(descriptionDetails)
    }
}
