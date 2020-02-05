//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewControllerDelegate
protocol PlayerDetailViewControllerDelegate: AnyObject {
    func didEdit(player: PlayerResponseModel)
}

// MARK: - PlayerDetailViewController
final class PlayerDetailViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerDetailView: PlayerDetailView!

    weak var delegate: PlayerDetailViewControllerDelegate?
    var player: PlayerResponseModel?

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifier.editPlayer.rawValue,
            let destinationViewController = segue.destination as? PlayerEditViewController else {
                return
        }
        
        let presenter = playerDetailView.presenter
        destinationViewController.viewType = presenter?.destinationViewType ?? .text
        destinationViewController.playerEditModel = presenter?.playerEditModel
        destinationViewController.playerItemsEditModel = presenter?.playerItemsEditModel
        destinationViewController.delegate = self
    }

    // MARK: - Private methods
    private func setupTitle() {
        title = playerDetailView.title
    }
    
    private func setupView() {
        guard let player = player else { return }
        
        let presenter = PlayerDetailPresenter(player: player)
        playerDetailView.delegate = self
        playerDetailView.presenter = presenter
    }

    private func reloadData() {
        playerDetailView.reloadData()
    }

}

// MARK: - PlayerDetailViewDelegate
extension PlayerDetailViewController: PlayerDetailViewDelegate {
    func didRequestEditView() {
        performSegue(withIdentifier: SegueIdentifier.editPlayer.rawValue, sender: nil)
    }
}

// MARK: - PlayerEditViewControllerDelegate
extension PlayerDetailViewController: PlayerEditViewControllerDelegate {
    func didFinishEditing(player: PlayerResponseModel) {
        setupTitle()
        playerDetailView.updateData(player: player)
        reloadData()
        delegate?.didEdit(player: player)
    }
}
