//
//  PlayerAddViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 10/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - AddPlayerDelegate
protocol AddPlayerDelegate: AnyObject {
    func playerWasAdded()
}

// MARK: - PlayerAddViewController
final class PlayerAddViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerAddView: PlayerAddView!
    
    weak var delegate: AddPlayerDelegate?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTitle()
    }
    
    private func setupTitle() {
        title = "Add Player"
    }
    
    private func setupView() {
        let presenter = PlayerAddPresenter(view: playerAddView)
        playerAddView.delegate = self
        playerAddView.presenter = presenter
        playerAddView.setupView()
    }

}

// MARK: - PlayerAddViewDelegate
extension PlayerAddViewController: PlayerAddViewDelegate {
    func addRightBarButtonItem(_ barButtonItem: UIBarButtonItem) {
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didAddPlayer() {
        delegate?.playerWasAdded()
        navigationController?.popViewController(animated: true)
    }
}
