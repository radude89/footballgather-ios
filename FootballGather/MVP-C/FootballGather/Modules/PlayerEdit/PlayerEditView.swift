//
//  PlayerEditView.swift
//  FootballGather
//
//  Created by Radu Dan on 25/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerEditViewProtocol
protocol PlayerEditViewProtocol: AnyObject {
    var title: String { get }
    
    func setupView()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handleSuccessfulPlayerUpdate(_ player: PlayerResponseModel)
}

// MARK: - PlayerEditViewDelegate
protocol PlayerEditViewDelegate: AnyObject {
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem)
    func presentAlert(title: String, message: String)
    func didFinishEditingPlayer(_ player: PlayerResponseModel)
}

// MARK: - PlayerEditView
final class PlayerEditView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerEditTextField: UITextField!
    @IBOutlet weak var playerTableView: UITableView!

    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self)
    
    weak var delegate: PlayerEditViewDelegate?
    var presenter: PlayerEditPresenterProtocol!
    
    // MARK: - Setup
    private func setupNavigationItems() {
        doneButton.isEnabled = false
        delegate?.addRightBarButtonItem(doneButton)
    }
    
    private func setupPlayerEditTextField() {
        playerEditTextField.placeholder = presenter.playerRowValue
        playerEditTextField.text = presenter.playerRowValue
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        playerEditTextField.isHidden = presenter.isSelectionViewType
    }
    
    private func setupTableView() {
        playerTableView.isHidden = !presenter.isSelectionViewType
    }
    
    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = presenter.doneButtonIsEnabled(newValue: playerEditTextField.text)
    }

    @objc private func doneAction(sender: UIBarButtonItem) {
        presenter.updatePlayerBasedOnViewType(inputFieldValue: playerEditTextField.text)
    }
    
}

// MARK: - Public methods
extension PlayerEditView: PlayerEditViewProtocol {
    var title: String {
        return presenter.title
    }
    
    func setupView() {
        setupNavigationItems()
        setupPlayerEditTextField()
        setupTableView()
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handleSuccessfulPlayerUpdate(_ player: PlayerResponseModel) {
        delegate?.didFinishEditingPlayer(player)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }

        cell.textLabel?.text = presenter.itemRowTextDescription(indexPath: indexPath)
        cell.accessoryType = presenter.isSelectedIndexPath(indexPath) ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItemIndex = presenter.selectedItemIndex {
            clearAccessoryType(forSelectedIndex: selectedItemIndex)
        }

        presenter.updateSelectedItemIndex(indexPath.row)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        doneButton.isEnabled = presenter.doneButtonIsEnabled(selectedIndexPath: indexPath)
    }

    private func clearAccessoryType(forSelectedIndex selectedItemIndex: Int) {
        let indexPath = IndexPath(row: selectedItemIndex, section: 0)
        playerTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
