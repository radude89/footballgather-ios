//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var confirmPlayersView: ConfirmPlayersView!

    var playersDictionary: [TeamSection: [PlayerResponseModel]]?

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.gather.rawValue,
            let gatherViewController = segue.destination as? GatherViewController,
            let gatherModel = confirmPlayersView.presenter.gatherModel {
            gatherViewController.gatherModel = gatherModel
        }
    }

}

// MARK: - ConfirmPlayersViewDelegate
extension ConfirmPlayersViewController: ConfirmPlayersViewDelegate {
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didStartGather() {
        performSegue(withIdentifier: SegueIdentifier.gather.rawValue, sender: nil)
    }
}
