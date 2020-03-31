//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController, Coordinatable {
    
    // MARK: - Properties
    @IBOutlet weak var confirmPlayersView: ConfirmPlayersView!
    
    var playersDictionary: [TeamSection: [PlayerResponseModel]]?
    
    weak var coordinator: Coordinator?
    private var confirmCoordinator: ConfirmPlayersCoordinator? { coordinator as? ConfirmPlayersCoordinator }
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let presenter = ConfirmPlayersPresenter(view: confirmPlayersView, playersDictionary: playersDictionary ?? [:])
        confirmPlayersView.delegate = self
        confirmPlayersView.presenter = presenter
        confirmPlayersView.setupView()
    }
    
}

// MARK: - ConfirmPlayersViewDelegate
extension ConfirmPlayersViewController: ConfirmPlayersViewDelegate {
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didStartGather(_ gather: GatherModel) {
        confirmCoordinator?.navigateToGatherScreen(with: gather)
    }
}
