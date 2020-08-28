//
//  PlayerEditViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 02/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerEditViewController
final class PlayerEditViewController: UIViewController, Coordinatable {

    // MARK: - Properties
    @IBOutlet weak var playerEditView: PlayerEditView!
    
    var viewType: PlayerEditViewType = .text
    var playerEditModel: PlayerEditModel?
    var playerItemsEditModel: PlayerItemsEditModel?
    
    weak var coordinator: Coordinator?
    private var editCoordinator: PlayerEditCoordinator? { coordinator as? PlayerEditCoordinator }

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTitle()
    }
    
    private func setupView() {
        guard let playerEditModel = playerEditModel else { return }
        
        let presenter = PlayerEditPresenter(view: playerEditView,
                                            viewType: viewType,
                                            playerEditModel: playerEditModel,
                                            playerItemsEditModel: playerItemsEditModel)
        playerEditView.delegate = self
        playerEditView.presenter = presenter
        playerEditView.setupView()
    }
    
    private func setupTitle() {
        title = playerEditView.title
    }
    
}

// MARK: - PlayerEditViewDelegate
extension PlayerEditViewController: PlayerEditViewDelegate {
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didFinishEditingPlayer(_ player: PlayerResponseModel) {
        editCoordinator?.didFinishEditingPlayer(player)
    }
}
