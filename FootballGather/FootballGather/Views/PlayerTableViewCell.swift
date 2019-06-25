//
//  PlayerTableViewCell.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 24/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var checkboxImageView: UIImageView!
    @IBOutlet weak var playerCellLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var skillLabel: UILabel!
    
    var playerIsSelected: Bool = false {
        didSet {
            if playerIsSelected {
                checkboxImageView.image = UIImage(named: "ticked")
            } else {
                checkboxImageView.image = UIImage(named: "unticked")
            }
        }
    }
    
    private enum Constants {
        static let playerContentLeftPadding: CGFloat = 10.0
        static let playerContentAndIconLeftPadding: CGFloat = -20.0
    }
    
    func setupDefaultView() {
        playerCellLeftConstraint.constant = Constants.playerContentAndIconLeftPadding
        checkboxImageView.isHidden = true
        playerIsSelected = false
    }
    
    func setupSelectionView() {
        playerCellLeftConstraint.constant = Constants.playerContentLeftPadding
        checkboxImageView.isHidden = false
    }
    
}
