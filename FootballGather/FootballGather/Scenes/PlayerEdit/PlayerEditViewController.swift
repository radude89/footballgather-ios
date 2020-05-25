//
//  PlayerEditViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerEditViewController
final class PlayerEditViewController: UIViewController, PlayerEditViewable {
    
    // MARK: - Properties
    @IBOutlet private weak var playerEditTextField: UITextField!
    @IBOutlet private weak var playerTableView: UITableView!
    
    private var barButtonItem: UIBarButtonItem!
    lazy var loadingView = LoadingView.initToView(view)
    
    var interactor: PlayerEditInteractorProtocol!
    var router: PlayerEditRouterProtocol = PlayerEditRouter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBarButtonItem(title: "Done", isEnabled: false)
        setupTextField()
        setupTableView()
        setupTitle()
    }
    
    private func setupBarButtonItem(title: String, isEnabled: Bool) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = barButtonItem
        
        barButtonItem.isEnabled = isEnabled
    }
    
    private func setupTextField() {
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        let request = PlayerEdit.ConfigureField.Request()
        interactor.configureField(request: request)
    }
    
    private func setupTitle() {
        let request = PlayerEdit.ConfigureTitle.Request()
        interactor.configureTitle(request: request)
    }
    
    private func setupTableView() {
        let request = PlayerEdit.ConfigureTable.Request()
        interactor.configureTable(request: request)
    }
    
    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        let request = PlayerEdit.UpdateField.Request(text: textField.text)
        interactor.updateValue(request: request)
    }
    
    @objc private func done(sender: UIBarButtonItem) {
        showLoadingView()
        
        let request = PlayerEdit.Done.Request(text: playerEditTextField.text)
        interactor.endEditing(request: request)
    }
    
}

// MARK: - Configuration
extension PlayerEditViewController: PlayerEditViewDisplayable {
    func displayTitle(viewModel: PlayerEdit.ConfigureTitle.ViewModel) {
        title = viewModel.title
    }
    
    func displayField(viewModel: PlayerEdit.ConfigureField.ViewModel) {
        playerEditTextField.placeholder = viewModel.placeholder
        playerEditTextField.text = viewModel.text
        playerEditTextField.isHidden = viewModel.isHidden
    }
    
    func displayTable(viewModel: PlayerEdit.ConfigureTable.ViewModel) {
        playerTableView.isHidden = viewModel.tableViewIsHidden
    }
    
    func displayBarButton(viewModel: PlayerEditBarButtonViewModel) {
        barButtonItem.isEnabled = viewModel.barButtonIsEnabled
    }
    
    func setSelected(viewModel: PlayerEdit.UpdateSelection.ViewModel) {
        if let unselectedIndexPath = viewModel.unselectedIndexPath {
            let cellForUnselectedRow = playerTableView.cellForRow(at: unselectedIndexPath)
            cellForUnselectedRow?.accessoryType = .none
        }
        
        let cellForSelectedRow = playerTableView.cellForRow(at: viewModel.selectedIndexPath)
        cellForSelectedRow?.accessoryType = .checkmark
    }
    
    func dismissEditView() {
        router.dismissEditView()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let request = PlayerEdit.RowsCount.Request()
        return interactor.numberOfRows(request: request)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }
        
        let request = PlayerEdit.RowDetails.Request(indexPath: indexPath)
        let rowViewModel = interactor.rowDetails(request: request)
        
        cell.textLabel?.text = rowViewModel.title
        cell.accessoryType = rowViewModel.isSelected == true ? .checkmark : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateSelection(indexPath: indexPath)
        selectPlayer(at: indexPath)
    }
    
    private func updateSelection(indexPath: IndexPath) {
        let request = PlayerEdit.UpdateSelection.Request(indexPath: indexPath)
        interactor.updateSelection(request: request)
    }
    
    private func selectPlayer(at indexPath: IndexPath) {
        let request = PlayerEdit.SelectRow.Request(indexPath: indexPath)
        interactor.selectRow(request: request)
    }
}

// MARK: - Loadable
extension PlayerEditViewController: Loadable {}

// MARK: - Error Handler
extension PlayerEditViewController: PlayerEditViewErrorHandler {}
