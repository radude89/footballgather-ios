//
//  PlayerDetailInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerDetailInteractor
final class PlayerDetailInteractor: PlayerDetailInteractable {
    
    var presenter: PlayerDetailPresenterProtocol
    weak var delegate: PlayerDetailDelegate?
    
    private var player: PlayerResponseModel
    
    init(presenter: PlayerDetailPresenterProtocol = PlayerDetailPresenter(),
         player: PlayerResponseModel,
         delegate: PlayerDetailDelegate? = nil) {
        self.presenter = presenter
        self.player = player
        self.delegate = delegate
        
        presenter.sections = PlayerDetailSectionFactory.makeSections(from: player)
    }
    
}

// MARK: - Configure
extension PlayerDetailInteractor: PlayerDetailInteractorConfigurable {
    func configureTitle(request: PlayerDetail.ConfigureTitle.Request) {
        let response = PlayerDetail.ConfigureTitle.Response(playerName: player.name)
        presenter.presentTitle(response: response)
    }
}

// MARK: Table Delegate
extension PlayerDetailInteractor: PlayerDetailInteractorTableDelegate {
    func numberOfSections(request: PlayerDetail.SectionsCount.Request) -> Int {
        let response = PlayerDetail.SectionsCount.Response()
        return presenter.numberOfSections(response: response)
    }
    
    func numberOfRowsInSection(request: PlayerDetail.RowsCount.Request) -> Int {
        let response = PlayerDetail.RowsCount.Response(section: request.section)
        return presenter.numberOfRowsInSection(response: response)
    }
    
    func rowDetails(request: PlayerDetail.RowDetails.Request) -> PlayerDetail.RowDetails.ViewModel {
        let response = PlayerDetail.RowDetails.Response(indexPath: request.indexPath)
        return presenter.rowDetails(response: response)
    }
    
    func titleForHeaderInSection(request: PlayerDetail.SectionTitle.Request) -> PlayerDetail.SectionTitle.ViewModel {
        let response = PlayerDetail.SectionTitle.Response(section: request.section)
        return presenter.titleForHeaderInSection(response: response)
    }
    
    func selectRow(request: PlayerDetail.SelectRow.Request) {
        let rowDetails = self.rowDetails(indexPath: request.indexPath)
        let items = self.items(for: rowDetails.editableField)
        let selectedItemIndex = items.firstIndex(of: rowDetails.value.lowercased())
        let editablePlayerDetails = PlayerEditable(player: player,
                                                   items: items,
                                                   selectedItemIndex: selectedItemIndex,
                                                   rowDetails: rowDetails)
        
        let response = PlayerDetail.SelectRow.Response(playerEditable: editablePlayerDetails, delegate: self)
        presenter.presentEditView(response: response)
    }
    
    private func rowDetails(indexPath: IndexPath) -> PlayerDetailRow {
        let sections = presenter.sections
        let section = indexPath.section
        let row = indexPath.row
        
        return sections[section].rows[row]
    }
     
     private func items(for editableField: PlayerEditableFieldOption) -> [String] {
         switch editableField {
         case .position:
             return PlayerPosition.allCases.map { $0.rawValue }
             
         case .skill:
             return PlayerSkill.allCases.map { $0.rawValue }
             
         default:
             return []
         }
     }
}

// MARK: - PlayerEditDelegate
extension PlayerDetailInteractor: PlayerEditDelegate {
    func didUpdate(player: PlayerResponseModel) {
        self.player = player
        
        let sections = PlayerDetailSectionFactory.makeSections(from: player)
        let response = PlayerDetail.Update.Response(playerName: player.name,
                                                    sections: sections)
        presenter.updateView(response: response)
        
        delegate?.didUpdate(player: player)
    }
}
