//
//  PlayerTableViewCell.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 24/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerTableViewCell: UITableViewCell, PlayerTableViewCellProtocol {
    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var playerCellLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    
    private enum Constants {
        static let playerContentLeftPadding: CGFloat = 10.0
        static let playerContentAndIconLeftPadding: CGFloat = -20.0
    }
    
    func setupDefaultView() {
        playerCellLeftConstraint.constant = Constants.playerContentAndIconLeftPadding
        setupCheckBoxImage(isSelected: false)
        checkboxImageView.isHidden = true
    }
    
    func setupViewForSelection(isSelected: Bool) {
        playerCellLeftConstraint.constant = Constants.playerContentLeftPadding
        checkboxImageView.isHidden = false
        setupCheckBoxImage(isSelected: isSelected)
    }
    
    func setupCheckBoxImage(isSelected: Bool) {
        let imageName = isSelected ? "ticked" : "unticked"
        checkboxImageView.image = UIImage(named: imageName)
    }
    
    func set(nameDescription: String) {
        nameLabel.text = nameDescription
    }
    
    func set(positionDescription: String) {
        positionLabel.text = positionDescription
    }
    
    func set(skillDescription: String) {
        skillLabel.text = skillDescription
    }
    
}
