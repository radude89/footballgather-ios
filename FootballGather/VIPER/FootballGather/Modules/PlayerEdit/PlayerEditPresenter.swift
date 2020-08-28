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
    var interactor: PlayerEditInteractorProtocol
    var router: PlayerEditRouterProtocol
    weak var delegate: PlayerEditDelegate?
    
    // MARK: - Init
    init(view: PlayerEditViewProtocol? = nil,
         interactor: PlayerEditInteractorProtocol,
         router: PlayerEditRouterProtocol = PlayerEditRouter(),
         delegate: PlayerEditDelegate? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
}

// MARK: - View Configuration
extension PlayerEditPresenter: PlayerEditPresenterViewConfiguration {
    func viewDidLoad() {
        view?.setupBarButtonItem(title: "Done")
        view?.setBarButtonState(isEnabled: false)
        view?.setupTextField()
        
        configureTextField()
        
        view?.setTableViewVisibility(isHidden: !isSelectionViewType)
    }
    
    private func configureTextField() {
        let rowValue = interactor.playerEditable.rowDetails?.value
        let isHidden = isSelectionViewType
        view?.setTextField(text: rowValue, placeholder: rowValue, isHidden: isHidden)
    }
    
    private var isSelectionViewType: Bool {
        interactor.playerEditable.items.isEmpty == false
    }
}

// MARK: - TextField Handler
extension PlayerEditPresenter: PlayerEditPresenterTextFieldHandler {
    func textFieldDidChange() {
        let newValue = view?.textFieldText
        let barButtonIsEnabled = self.barButtonIsEnabled(for: newValue)
        
        view?.setBarButtonState(isEnabled: barButtonIsEnabled)
    }
    
    private func barButtonIsEnabled(for newValue: String?) -> Bool {
        let oldValue = interactor.playerEditable.rowDetails?.value
        let isNameField = interactor.playerEditable.rowDetails?.editableField == .name
        let valuesAreDifferent = newValue?.lowercased() != oldValue?.lowercased()
        
        if isNameField {
            return valuesAreDifferent && newValue?.isEmpty == false
        } else {
            return valuesAreDifferent
        }
    }
}

// MARK: - Interactor
extension PlayerEditPresenter: PlayerEditPresenterServiceInteractable {
    func endEditing() {
        view?.showLoadingView()
        interactor.commitUpdates(with: view?.textFieldText)
        interactor.updatePlayer()
    }
}

// MARK: - Service Handler
extension PlayerEditPresenter: PlayerEditPresenterServiceHandler {
    func playerWasUpdated() {
        view?.hideLoadingView()
        delegate?.didUpdate(player: interactor.playerEditable.player)
        router.dismissEditView()
    }
    
    func serviceFailedToUpdatePlayer() {
        view?.hideLoadingView()
        view?.handleError(title: "Error update", message: "Unable to update player. Please try again.")
    }
}

// MARK: - Data Source
extension PlayerEditPresenter: PlayerEditDataSource {
    var numberOfRows: Int {
        interactor.playerEditable.items.count
    }
    
    func itemRow(at index: Int) -> PlayerEditRow? {
        guard isSelectionViewType else {
            return nil
        }
        
        let title = interactor.playerEditable.items[index].capitalized
        let isSelected = rowIsSelected(at: index)
        
        return PlayerEditRow(title: title, isSelected: isSelected)
    }
    
    private func rowIsSelected(at index: Int) -> Bool {
        interactor.playerEditable.selectedItemIndex == index
    }
    
    func selectRow(at index: Int) {
        guard rowIsSelected(at: index) == false else {
            return
        }
        
        updateViewSelection(for: index)
        interactor.updateSelectedItemIndex(index)
        updateBarButtonState(basedOn: index)
    }
    
    private func updateViewSelection(for index: Int) {
        if let oldIndex = interactor.playerEditable.selectedItemIndex {
            view?.setSelected(false, at: IndexPath(row: oldIndex, section: 0))
        }
        
        view?.setSelected(true, at: IndexPath(row: index, section: 0))
    }
    
    private func updateBarButtonState(basedOn index: Int) {
        let newValue = interactor.playerEditable.items[index]
        let oldValue = interactor.playerEditable.rowDetails?.value
        let valuesAreDifferent = newValue.lowercased() != oldValue?.lowercased()
        
        view?.setBarButtonState(isEnabled: valuesAreDifferent)
    }
}

// MARK: - PlayerEditRow
struct PlayerEditRow {
    let title: String
    let isSelected: Bool
}
