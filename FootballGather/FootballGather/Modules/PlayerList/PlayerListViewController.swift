//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController, PlayerListViewable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionButton: UIButton!
    
    private var barButtonItem: UIBarButtonItem!
    
    lazy var loadingView = LoadingView.initToView(view)
    
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    var presenter: PlayerListPresenterProtocol = PlayerListPresenter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Selectors
    @objc private func selectPlayers() {
        presenter.selectPlayers()
    }
    
    @IBAction private func confirmOrAddPlayers(_ sender: Any) {
        presenter.confirmOrAddPlayers()
    }
    
}

// MARK: - Configuration
extension PlayerListViewController: PlayerListViewConfigurable {
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func setupBarButtonItem(title: String) {
        barButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(selectPlayers))
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func setBarButtonState(isEnabled: Bool) {
        barButtonItem.isEnabled = isEnabled
    }
    
    func setBarButtonTitle(_ title: String) {
        barButtonItem.title = title
    }
    
    func setBottomActionButtonTitle(_ title: String) {
        bottomActionButton.setTitle(title, for: .normal)
    }
    
    func setBottomActionButtonState(isEnabled: Bool) {
        bottomActionButton.isEnabled = isEnabled
    }
    
    func setupTableView() {
        playerTableView.tableFooterView = UIView()
    }
    
    func setViewInteraction(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
}

// MARK: - Reload
extension PlayerListViewController: PlayerListViewReloadable {
    func reloadData() {
        playerTableView.reloadData()
    }
    
    func reloadRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - Update
extension PlayerListViewController: PlayerListViewUpdatable {
    func displayDeleteConfirmationAlert(at index: Int) {
        let alertController = UIAlertController(title: "Delete player", message: "Are you sure you want to delete the selected player?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.confirmPlayerDeletion(at: index)
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func confirmPlayerDeletion(at index: Int) {
        presenter.deletePlayer(at: index)
    }
    
    func beginTableUpdates() {
        playerTableView.beginUpdates()
    }
    
    func deleteRows(at index: Int) {
        playerTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func endTableUpdates() {
        playerTableView.endUpdates()
    }
}

// MARK: - EmptyViewable
extension PlayerListViewController: EmptyViewable {
    func showEmptyView() {
        playerTableView.isHidden = true
        emptyView.isHidden = false
    }
    
    func hideEmptyView() {
        playerTableView.isHidden = false
        emptyView.isHidden = true
    }
    
    func retryAction() {
        presenter.retry()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }
        
        let index = indexPath.row
        let cellPresenter = presenter.cellPresenter(at: index)
        let player = presenter.player(at: index)
        
        cellPresenter.view = cell
        cellPresenter.setupView()
        cellPresenter.configure(with: player)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectRow(at: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        presenter.canEditRow
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        presenter.requestToDeletePlayer(at: indexPath.row)
    }
}

// MARK: - Loadable
extension PlayerListViewController: Loadable {}

// MARK: - Error Handler
extension PlayerListViewController: ErrorHandler {}
