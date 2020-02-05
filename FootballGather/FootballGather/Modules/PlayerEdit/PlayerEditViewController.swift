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
final class PlayerEditViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerEditView: PlayerEditView!

    weak var delegate: PlayerEditViewControllerDelegate?
    
    var viewType: PlayerEditViewType = .text
    var playerEditModel: PlayerEditModel?
    var playerItemsEditModel: PlayerItemsEditModel?

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
    
    func didFinishEditingPlayer() {
        delegate?.didFinishEditing(player: playerEditView.presenter.editablePlayer)
        navigationController?.popViewController(animated: true)
    }
}
