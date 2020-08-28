//
//  PlayerDetailTableViewCell.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerDetailTableViewCell: UITableViewCell, PlayerDetailTableViewCellProtocol {
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    func setLeftLabelText(_ text: String) {
        leftLabel.text = text
    }
    
    func setRightLabelText(_ text: String) {
        rightLabel.text = text
    }
}
