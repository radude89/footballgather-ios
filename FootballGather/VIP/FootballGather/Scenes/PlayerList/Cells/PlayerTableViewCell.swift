//
//  PlayerTableViewCell.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 24/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerTableViewCell: UITableViewCell {
    @IBOutlet private weak var checkboxImageView: UIImageView!
    @IBOutlet private weak var playerCellLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var positionLabel: UILabel!
    @IBOutlet private weak var skillLabel: UILabel!
    
    private enum Constants {
        static let playerContentLeftPadding: CGFloat = 10.0
        static let playerContentAndIconLeftPadding: CGFloat = -20.0
    }
    
    func setupCheckBoxImage(isSelected: Bool) {
        let imageName = isSelected ? "ticked" : "unticked"
        checkboxImageView.image = UIImage(named: imageName)
    }
    
    func set(isListView: Bool) {
        if isListView {
            setupDefaultView()
        } else {
            setupViewForSelection()
        }
    }
    
    private func setupDefaultView() {
        playerCellLeftConstraint.constant = Constants.playerContentAndIconLeftPadding
        checkboxImageView.isHidden = true
    }
    
    private func setupViewForSelection() {
        playerCellLeftConstraint.constant = Constants.playerContentLeftPadding
        checkboxImageView.isHidden = false
    }
    
    func set(isSelected: Bool) {
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
