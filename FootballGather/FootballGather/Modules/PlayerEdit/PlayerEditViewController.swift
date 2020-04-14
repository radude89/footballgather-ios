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
    @IBOutlet weak var playerEditTextField: UITextField!
    @IBOutlet weak var playerTableView: UITableView!
    
    private var barButtonItem: UIBarButtonItem!
    lazy var loadingView = LoadingView.initToView(view)
    
    var presenter: PlayerEditPresenterProtocol!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Selectors
    @objc private func textFieldDidChange(textField: UITextField) {
        presenter.textFieldDidChange()
    }
    
    @objc private func done(sender: UIBarButtonItem) {
        presenter.endEditing()
    }
    
}

// MARK: - Configuration
extension PlayerEditViewController: PlayerEditViewConfigurable {
    var textFieldText: String? {
        playerEditTextField.text
    }
    
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func setupBarButtonItem(title: String) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func setupTextField() {
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func setTextField(text: String?, placeholder: String?, isHidden: Bool) {
        playerEditTextField.placeholder = placeholder
        playerEditTextField.text = text
        playerEditTextField.isHidden = isHidden
    }
    
    func setTableViewVisibility(isHidden: Bool) {
        playerTableView.isHidden = isHidden
    }
    
    func setBarButtonState(isEnabled: Bool) {
        barButtonItem.isEnabled = isEnabled
    }
    
    func setSelected(_ selected: Bool, at indexPath: IndexPath) {
        playerTableView.cellForRow(at: indexPath)?.accessoryType = selected ? .checkmark : .none
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }
        
        let row = presenter.itemRow(at: indexPath.row)

        cell.textLabel?.text = row?.title
        cell.accessoryType = row?.isSelected == true ? .checkmark : .none

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectRow(at: indexPath.row)
    }
}

// MARK: - Loadable
extension PlayerEditViewController: Loadable {}

// MARK: - Error Handler
extension PlayerEditViewController: ErrorHandler {}
