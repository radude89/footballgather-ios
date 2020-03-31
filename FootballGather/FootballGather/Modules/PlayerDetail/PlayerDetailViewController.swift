//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewController
final class PlayerDetailViewController: UIViewController, Coordinatable {

    // MARK: - Properties
    @IBOutlet weak var playerDetailView: PlayerDetailView!
    
    var player: PlayerResponseModel?
    
    weak var coordinator: Coordinator?
    private var detailCoordinator: PlayerDetailCoordinator? { coordinator as? PlayerDetailCoordinator }

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
    
    // MARK: - Private methods
    func setupTitle() {
        title = playerDetailView.title
    }
    
    private func setupView() {
        guard let player = player else { return }
        
        let presenter = PlayerDetailPresenter(player: player)
        playerDetailView.delegate = self
        playerDetailView.presenter = presenter
    }

    func reloadData() {
        playerDetailView.reloadData()
    }
    
    func updateData(player: PlayerResponseModel) {
        playerDetailView.updateData(player: player)
    }

}

// MARK: - PlayerDetailViewDelegate
extension PlayerDetailViewController: PlayerDetailViewDelegate {
    func didRequestEditView(with viewType: PlayerEditViewType,
                            playerEditModel: PlayerEditModel?,
                            playerItemsEditModel: PlayerItemsEditModel?) {
        
        detailCoordinator?.navigateToEditScreen(viewType: viewType,
                                                playerEditModel: playerEditModel,
                                                playerItemsEditModel: playerItemsEditModel)
    }
}
