//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController, Coordinatable {

    // MARK: - Properties
    @IBOutlet weak var playerListView: PlayerListView!
    
    weak var coordinator: Coordinator?
    private var listCoordinator: PlayerListCoordinator? { coordinator as? PlayerListCoordinator }

    // MARK: - Setup methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func reloadView() {
        playerListView.loadPlayers()
    }
    func didEdit(player: PlayerResponseModel) {
        playerListView.didEdit(player: player)
    }
    
    func toggleViewState() {
        playerListView.toggleViewState()
    }
    
    private func setupView() {
        let presenter = PlayerListPresenter(view: playerListView)
        playerListView.delegate = self
        playerListView.presenter = presenter
        playerListView.setupView()
    }

}

// MARK: - PlayerListViewDelegate
extension PlayerListViewController: PlayerListViewDelegate {
    func didRequestToChangeTitle(_ title: String) {
        self.title = title
    }
    
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func viewPlayerDetails(_ player: PlayerResponseModel) {
        listCoordinator?.navigateToPlayerDetails(player: player)
    }
    
    func addPlayer() {
        listCoordinator?.navigateToPlayerAddScreen()
    }
    
    func confirmPlayers(with playersDictionary: [TeamSection: [PlayerResponseModel]]) {
        listCoordinator?.navigateToConfirmPlayersScreen(with: playersDictionary)
    }
    
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didRequestPlayerDeletion() {
        let alertController = UIAlertController(title: "Delete player", message: "Are you sure you want to delete the selected player?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.playerListView.confirmPlayerDeletion()
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.playerListView.cancelPlayerDeletion()
        }
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
