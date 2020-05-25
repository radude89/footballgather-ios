//
//  PlayerEditPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 25/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerEditPresenter
final class PlayerEditPresenter: PlayerEditPresentable {
    
    // MARK: - Properties
    weak var view: PlayerEditViewProtocol?
    
    // MARK: - Init
    init(view: PlayerEditViewProtocol? = nil) {
        self.view = view
    }
    
}

// MARK: - View Configuration
extension PlayerEditPresenter: PlayerEditPresenterConfigurable {
    func presentField(response: PlayerEdit.ConfigureField.Response) {
        let rowValue = response.rowDetailsValue
        let viewModel = PlayerEdit.ConfigureField.ViewModel(placeholder: rowValue,
                                                            text: rowValue,
                                                            isHidden: response.editableItemsAreEmpty)
        view?.displayField(viewModel: viewModel)
    }
    
    func presentTitle(response: PlayerEdit.ConfigureTitle.Response) {
        let viewModel = PlayerEdit.ConfigureTitle.ViewModel(title: response.playerName.uppercased())
        view?.displayTitle(viewModel: viewModel)
    }
    
    func presentTable(response: PlayerEdit.ConfigureTable.Response) {
        let viewModel = PlayerEdit.ConfigureTable.ViewModel(tableViewIsHidden: !response.editableItemsAreEmpty)
        view?.displayTable(viewModel: viewModel)
    }
}
    
// MARK: - Actionable
extension PlayerEditPresenter: PlayerEditPresenterActionable {
    func updateView(response: PlayerEdit.UpdateField.Response) {
        let barButtonIsEnabled = self.barButtonIsEnabled(response: response)
        let viewModel = PlayerEdit.UpdateField.ViewModel(barButtonIsEnabled: barButtonIsEnabled)
        view?.displayBarButton(viewModel: viewModel)
    }
    
    private func barButtonIsEnabled(response: PlayerEdit.UpdateField.Response) -> Bool {
        let newValue = response.updatedValue
        let oldValue = response.currentRowDetailsValue
        let isNameField = response.editableFieldOption == .name
        let valuesAreDifferent = newValue?.lowercased() != oldValue?.lowercased()
        
        if isNameField {
            return valuesAreDifferent && newValue?.isEmpty == false
        } else {
            return valuesAreDifferent
        }
    }

    func dismissEditView() {
        view?.hideLoadingView()
        view?.dismissEditView()
    }
    
    func presentError(response: PlayerEdit.ErrorResponse) {
        view?.hideLoadingView()
        
        let viewModel = PlayerEdit.ErrorViewModel(errorTitle: "Error update",
                                                  errorMessage: "Unable to update player. Please try again.")
        view?.displayError(viewModel: viewModel)
    }
}

// MARK: - Table Delegate
extension PlayerEditPresenter: PlayerEditPresenterTableDelegate {
    func rowDetails(response: PlayerEdit.RowDetails.Response) -> PlayerEdit.RowDetails.ViewModel {
        let index = response.indexPath.row
        let title = response.editablePlayer.items[index].capitalized
        let viewModel = PlayerEdit.RowDetails.ViewModel(title: title,
                                                        isSelected: response.isSelected)
        return viewModel
    }
    
    func updateViewSelection(response: PlayerEdit.UpdateSelection.Response) {
        var oldIndexPath: IndexPath?
        
        if let oldSelectedIndex = response.selectedItemIndex {
            oldIndexPath = IndexPath(row: oldSelectedIndex, section: 0)
        }
        
        let viewModel = PlayerEdit.UpdateSelection.ViewModel(unselectedIndexPath: oldIndexPath,
                                                             selectedIndexPath: response.indexPath)
        view?.setSelected(viewModel: viewModel)
    }
    
    func updateSelectedPlayer(response: PlayerEdit.SelectRow.Response) {
        let newValue = response.editablePlayer.items[response.index]
        let oldValue = response.editablePlayer.rowDetails?.value
        let valuesAreDifferent = newValue.lowercased() != oldValue?.lowercased()
        
        let viewModel = PlayerEdit.SelectRow.ViewModel(barButtonIsEnabled: valuesAreDifferent)
        view?.displayBarButton(viewModel: viewModel)
    }
}
