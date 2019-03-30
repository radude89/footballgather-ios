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
    func playerWasAdded(name: String)
}

// MARK: - PlayerAddViewController
class PlayerAddViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var playerNameTextField: UITextField!
    private lazy var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneAction))
    lazy var loadingView = LoadingView.initToView(self.view)
    
    weak var delegate: AddPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Player"
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false
        
        playerNameTextField.placeholder = "Enter name of the player"
        playerNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc
    func doneAction(sender: UIBarButtonItem) {
        guard let playerName = playerNameTextField.text else {
            return
        }
        
        showLoadingView()
        
        let player = PlayerCreateModel(name: playerName)
        createPlayer(player) { [weak self] playerWasCreated in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingView()
                
                if playerWasCreated {
                    self.delegate?.playerWasAdded(name: playerName)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    AlertHelper.present(in: self, title: "Error update", message: "Unable to create player. Please try again.")
                }
            }
        }
    }
    
    @objc
    func textFieldDidChange(textField: UITextField) {
        if textField.text?.isEmpty == false {
            doneButton.isEnabled = true
        } else {
            doneButton.isEnabled = false
        }
    }
    
    private func createPlayer(_ player: PlayerCreateModel, completion: @escaping (Bool) -> Void) {
        let service = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
        service.create(player) { result in
            if case .success(_) = result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
}

// MARK: - Loadable
extension PlayerAddViewController: Loadable {}
