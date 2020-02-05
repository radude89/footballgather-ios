//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListTogglable
protocol PlayerListTogglable: AnyObject {
    func toggleViewState()
}

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerListView: PlayerListView!

    // MARK: - Setup methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        let presenter = PlayerListPresenter(view: playerListView)
        playerListView.delegate = self
        playerListView.presenter = presenter
        playerListView.setupView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifier.confirmPlayers.rawValue:
            if let confirmPlayersViewController = segue.destination as? ConfirmPlayersViewController {
                confirmPlayersViewController.playersDictionary = playerListView.presenter.playersDictionary
            }

        case SegueIdentifier.playerDetails.rawValue:
            if let playerDetailsViewController = segue.destination as? PlayerDetailViewController,
                let player = playerListView.presenter.selectedPlayerForDetails {
                playerDetailsViewController.delegate = self
                playerDetailsViewController.player = player
            }

        case SegueIdentifier.addPlayer.rawValue:
            (segue.destination as? PlayerAddViewController)?.delegate = self

        default:
            break
        }
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
    
    func confirmOrAddPlayers(withSegueIdentifier segueIdentifier: String) {
        performSegue(withIdentifier: segueIdentifier, sender: nil)
    }
    
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    func didRequestPlayerDetails() {
        performSegue(withIdentifier: SegueIdentifier.playerDetails.rawValue, sender: nil)
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

// MARK: - PlayerDetailViewControllerDelegate
extension PlayerListViewController: PlayerDetailViewControllerDelegate {
    func didEdit(player: PlayerResponseModel) {
        playerListView.didEdit(player: player)
    }
}

// MARK: - AddPlayerDelegate
extension PlayerListViewController: AddPlayerDelegate {
    func playerWasAdded() {
        playerListView.loadPlayers()
    }
}

// MARK: - PlayerListTogglable
extension PlayerListViewController: PlayerListTogglable {
    func toggleViewState() {
        playerListView.toggleViewState()
    }
}
