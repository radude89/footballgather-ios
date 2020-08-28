//
//  PlayerEditViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerEditViewControllerDelegate
protocol PlayerEditViewControllerDelegate: AnyObject {
    func didFinishEditing(player: PlayerResponseModel)
}

// MARK: - PlayerEditViewController
final class PlayerEditViewController: UIViewController, Loadable {

    // MARK: - Properties
    @IBOutlet weak var playerEditTextField: UITextField!
    @IBOutlet weak var playerTableView: UITableView!

    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self.view)

    weak var delegate: PlayerEditViewControllerDelegate?
    var playerEditModel: PlayerEditModel!
    var viewType: PlayerEditViewType = .text
    var playerItemsEditModel: PlayerItemsEditModel?
    
    private var service = StandardNetworkService(resourcePath: "/api/players", authenticated: true)

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupPlayerEditTextField()
        setupTableView()
    }

    private func setupNavigationBar() {
        title = playerEditModel.playerRow.title
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }

    private func setupPlayerEditTextField() {
        playerEditTextField.placeholder = playerEditModel.playerRow.value
        playerEditTextField.text = playerEditModel.playerRow.value
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        playerEditTextField.isHidden = viewType == .selection
    }

    private func setupTableView() {
        playerTableView.isHidden = viewType != .selection
    }

    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = doneButtonIsEnabled(newValue: playerEditTextField.text)
    }

    @objc private func doneAction(sender: UIBarButtonItem) {
        guard shouldUpdatePlayer(inputFieldValue: playerEditTextField.text) else { return }

        showLoadingView()

        updatePlayerBasedOnViewType(inputFieldValue: playerEditTextField.text) { [weak self] updated in
            DispatchQueue.main.async {
                self?.hideLoadingView()

                if updated {
                    self?.handleSuccessfulPlayerUpdate()
                } else {
                    self?.handleServiceError()
                }
            }
        }
    }
    
    // MARK: - Private methods
    private func updatePlayerBasedOnViewType(inputFieldValue: String?, completion: @escaping (Bool) -> ()) {
        if viewType == .selection {
            updatePlayer(newFieldValue: selectedItemValue, completion: completion)
        } else {
            updatePlayer(newFieldValue: inputFieldValue, completion: completion)
        }
    }
    
    private func updatePlayer(newFieldValue: String?, completion: @escaping (Bool) -> ()) {
        guard let newFieldValue = newFieldValue else {
            completion(false)
            return
        }
        
        playerEditModel.player.update(usingField: playerEditModel.playerRow.editableField, value: newFieldValue)
        requestUpdatePlayer(completion: completion)
    }

    private func requestUpdatePlayer(completion: @escaping (Bool) -> ()) {
        let player = playerEditModel.player
        service.update(PlayerCreateModel(player), resourceID: ResourceID.integer(player.id)) { [weak self] result in
            if case .success(let updated) = result {
                self?.playerEditModel.player = player
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
    private func doneButtonIsEnabled(selectedIndexPath: IndexPath) -> Bool {
        if let newValue = playerItemsEditModel?.items[selectedIndexPath.row], playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }
    
    private func doneButtonIsEnabled(newValue: String?) -> Bool {
        if let newValue = newValue, playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }
    
    private func shouldUpdatePlayer(inputFieldValue: String?) -> Bool {
        if viewType == .selection {
            return newValueIsDifferentFromOldValue(newFieldValue: selectedItemValue)
        }
        
        return newValueIsDifferentFromOldValue(newFieldValue: inputFieldValue)
    }
    
    private var selectedItemValue: String? {
        guard let playerItemsEditModel = playerItemsEditModel else { return nil}
        
        return playerItemsEditModel.items[playerItemsEditModel.selectedItemIndex]
    }

    private func newValueIsDifferentFromOldValue(newFieldValue: String?) -> Bool {
        guard let newFieldValue = newFieldValue else { return false }
        
        return playerEditModel.playerRow.value.lowercased() != newFieldValue.lowercased()
    }

    private func handleSuccessfulPlayerUpdate() {
        delegate?.didFinishEditing(player: playerEditModel.player)
        navigationController?.popViewController(animated: true)
    }

    private func handleServiceError() {
        AlertHelper.present(in: self, title: "Error update", message: "Unable to update player. Please try again.")
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerItemsEditModel?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }

        cell.textLabel?.text = playerItemsEditModel?.items[indexPath.row].capitalized
        cell.accessoryType = playerItemsEditModel?.selectedItemIndex == indexPath.row ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItemIndex = playerItemsEditModel?.selectedItemIndex {
            clearAccessoryType(forSelectedIndex: selectedItemIndex)
        }

        playerItemsEditModel?.selectedItemIndex = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark

        doneButton.isEnabled = doneButtonIsEnabled(selectedIndexPath: indexPath)
    }

    private func clearAccessoryType(forSelectedIndex selectedItemIndex: Int) {
        let indexPath = IndexPath(row: selectedItemIndex, section: 0)
        playerTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

// MARK: - PlayerEditViewType
enum PlayerEditViewType {
    case text, selection
}

// MARK: - PlayerEditModel
struct PlayerEditModel {
    var player: PlayerResponseModel
    let playerRow: PlayerRow
}

// MARK: -
struct PlayerItemsEditModel {
    let items: [String]
    var selectedItemIndex: Int
}
