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
    var viewModel: PlayerEditViewModel!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupPlayerEditTextField()
        setupTableView()
    }
    
    private func setupNavigationBar() {
        title = viewModel.title
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
    }
    
    private func setupPlayerEditTextField() {
        playerEditTextField.placeholder = viewModel.playerRowValue
        playerEditTextField.text = viewModel.playerRowValue
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        playerEditTextField.isHidden = viewModel.isSelectionViewType
    }
    
    private func setupTableView() {
        playerTableView.isHidden = !viewModel.isSelectionViewType
    }
    
    // MARK: - Selectors
    @objc func textFieldDidChange(textField: UITextField) {
        doneButton.isEnabled = viewModel.doneButtonIsEnabled(newValue: playerEditTextField.text)
    }
    
    @objc func doneAction(sender: UIBarButtonItem) {
        guard viewModel.shouldUpdatePlayer(inputFieldValue: playerEditTextField.text) else { return }
        
        loadingView.show()
        
        viewModel.updatePlayerBasedOnViewType(inputFieldValue: playerEditTextField.text) { [weak self] updated in
            DispatchQueue.main.async {
                self?.loadingView.hide()
                
                if updated {
                    self?.handleSuccessfulPlayerUpdate()
                } else {
                    self?.handleServiceError()
                }
            }
        }
    }
    
    private func handleSuccessfulPlayerUpdate() {
        delegate?.didFinishEditing(player: viewModel.editablePlayer)
        navigationController?.popViewController(animated: true)
    }
    
    private func handleServiceError() {
        AlertHelper.present(in: self, title: "Error update", message: "Unable to update player. Please try again.")
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = viewModel.itemRowTextDescription(indexPath: indexPath)
        cell.accessoryType = viewModel.isSelectedIndexPath(indexPath) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedItemIndex = viewModel.selectedItemIndex {
            clearAccessoryType(forSelectedIndex: selectedItemIndex)
        }
        
        viewModel.updateSelectedItemIndex(indexPath.row)
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        doneButton.isEnabled = viewModel.doneButtonIsEnabled(selectedIndexPath: indexPath)
    }
    
    private func clearAccessoryType(forSelectedIndex selectedItemIndex: Int) {
        let indexPath = IndexPath(row: selectedItemIndex, section: 0)
        playerTableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
