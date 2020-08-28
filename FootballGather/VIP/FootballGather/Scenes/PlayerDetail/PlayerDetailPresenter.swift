//
//  PlayerDetailPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerDetailPresenter
final class PlayerDetailPresenter: PlayerDetailPresentable {
    
    weak var view: PlayerDetailViewProtocol?
    var sections: [PlayerDetailSection]
    
    init(view: PlayerDetailViewProtocol? = nil,
         sections: [PlayerDetailSection] = []) {
        self.view = view
        self.sections = sections
    }
    
}

// MARK: - View Configuration
extension PlayerDetailPresenter: PlayerDetailPresenterConfigurable {
    func presentTitle(response: PlayerDetail.ConfigureTitle.Response) {
        let viewModel = PlayerDetail.ConfigureTitle.ViewModel(title: response.playerName)
        view?.displayTitle(viewModel: viewModel)
    }
    
    func presentEditView(response: PlayerDetail.SelectRow.Response) {
        view?.showEditView(playerEditable: response.playerEditable, delegate: response.delegate)
    }
}

// MARK: - Table Delegate
extension PlayerDetailPresenter: PlayerDetailPresenterTableDelegate {
    func numberOfSections(response: PlayerDetail.SectionsCount.Response) -> Int {
        sections.count
    }
    
    func numberOfRowsInSection(response: PlayerDetail.RowsCount.Response) -> Int {
        sections[response.section].rows.count
    }
    
    func rowDetails(response: PlayerDetail.RowDetails.Response) -> PlayerDetail.RowDetails.ViewModel {
        let playerDetailRow = sections[response.indexPath.section].rows[response.indexPath.row]
        let viewModel = PlayerDetail.RowDetails.ViewModel(leftLabelText: playerDetailRow.title,
                                                          rightLabelText: playerDetailRow.value)
        
        return viewModel
    }
    
    func titleForHeaderInSection(response: PlayerDetail.SectionTitle.Response) -> PlayerDetail.SectionTitle.ViewModel {
        let title = sections[response.section].title.uppercased()
        let viewModel = PlayerDetail.SectionTitle.ViewModel(title: title)
        
        return viewModel
    }
    
    func rowDetails(at indexPath: IndexPath) -> PlayerDetailRow {
        sections[indexPath.section].rows[indexPath.row]
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        sections[section].title.uppercased()
    }
}

// MARK: - Update
extension PlayerDetailPresenter: PlayerDetailPresenterUpdatable {
    func updateView(response: PlayerDetail.Update.Response) {
        sections = response.sections
        
        let viewModel = PlayerDetail.ConfigureTitle.ViewModel(title: response.playerName)
        view?.displayTitle(viewModel: viewModel)
        
        view?.reloadData()
    }
}
