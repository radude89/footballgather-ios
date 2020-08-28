//
//  GatherViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 05/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - GatherViewController
final class GatherViewController: UIViewController, Coordinatable {

    // MARK: - Properties
    @IBOutlet weak var gatherView: GatherView!

    var gatherModel: GatherModel?
    
    weak var coordinator: Coordinator?
    private var gatherCoordinator: GatherCoordinator? { coordinator as? GatherCoordinator }

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTitle()
    }
    
    private func setupView() {
        guard let gatherModel = gatherModel else { return }
        
        let presenter = GatherPresenter(view: gatherView, gatherModel: gatherModel)
        gatherView.delegate = self
        gatherView.presenter = presenter
        gatherView.setupView()
    }

    private func setupTitle() {
        title = "Gather in progress"
    }

}

// MARK: - GatherViewDelegate
extension GatherViewController: GatherViewDelegate {
    func presentAlert(title: String, message: String) {
        AlertHelper.present(in: self, title: title, message: message)
    }
    
    func didEndGather() {
        gatherCoordinator?.didEndGather()
    }
    
    func presentConfirmAlertEndGather() {
        let alertController = UIAlertController(title: "End Gather", message: "Are you sure you want to end the gather?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.gatherView.confirmEndGather()
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
