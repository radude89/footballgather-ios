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
class PlayerEditViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var playerEditTextField: UITextField!
    @IBOutlet weak var playerTableView: UITableView!
    
    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self.view)
    
    weak var delegate: PlayerEditViewControllerDelegate?
    var viewType: PlayerEditViewType = .text
    
    var player: PlayerResponseModel?
    var playerRow: PlayerRow?

    var items: [String]?
    var selectedItemIndex: Int = -1
    
    enum PlayerEditViewType {
        case text, selection
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = playerRow?.title
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        playerEditTextField.placeholder = playerRow?.value
        playerEditTextField.text = playerRow?.value
        playerEditTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        setupUI()
    }
    
    private func setupUI() {
        if viewType == .selection {
            playerTableView.isHidden = false
            playerEditTextField.isHidden = true
        } else {
            playerTableView.isHidden = true
            playerEditTextField.isHidden = false
        }
    }
    
    @objc
    func doneAction(sender: UIBarButtonItem) {
        guard let playerRow = playerRow,
            var player = player,
            let newValue = viewType == .text ? playerEditTextField.text : items?[selectedItemIndex],
            playerRow.value.lowercased() != newValue.lowercased() else {
            return
        }
        
        loadingView.show()
        
        player.update(usingField: playerRow.editableField, value: newValue)
        
        updatePlayer(player) { [weak self] updated in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.loadingView.hide()
                
                if updated {
                    self.delegate?.didFinishEditing(player: player)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    AlertHelper.present(in: self, title: "Error update", message: "Unable to update player. Please try again.")
                }
            }
        }
    }
    
    @objc
    func textFieldDidChange(textField: UITextField) {
        if let newValue = textField.text,
            let oldValue = playerRow?.value,
            newValue != oldValue {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    private func updatePlayer(_ player: PlayerResponseModel, completion: @escaping (Bool) -> Void) {
        var service = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
        service.update(PlayerCreateModel(player), resourceID: ResourceID.integer(player.id)) { result in
            if case .success(let updated) = result {
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
}

// MARK: - Loadable conformance
extension PlayerEditViewController: Loadable {}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerEditViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let oldIndexPath = IndexPath(row: selectedItemIndex, section: 0)
        tableView.cellForRow(at: oldIndexPath)?.accessoryType = .none
        
        selectedItemIndex = indexPath.row
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        if let newValue = items?[selectedItemIndex],
            let oldValue = playerRow?.value,
            newValue.lowercased() != oldValue.lowercased() {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionCellIdentifier") else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = items?[indexPath.row].capitalized
        cell.accessoryType = indexPath.row == selectedItemIndex ? .checkmark : .none
        
        return cell
    }
}
