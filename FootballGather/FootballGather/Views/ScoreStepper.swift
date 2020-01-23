//
//  ScoreStepper.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

protocol ScoreStepperDelegate: AnyObject {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double)
}

class ScoreStepper: UIStackView {
    @IBOutlet weak var teamAStepper: UIStepper!
    @IBOutlet weak var teamBStepper: UIStepper!
    
    weak var delegate: ScoreStepperDelegate?
    
    @IBAction func teamAStepperValueChanged(_ sender: Any) {
        delegate?.stepper(teamAStepper, didChangeValueForTeam: .teamA, newValue: teamAStepper.value)
    }
    
    @IBAction func teamBStepperValueChanged(_ sender: Any) {
        delegate?.stepper(teamBStepper, didChangeValueForTeam: .teamB, newValue: teamBStepper.value)
    }
    
}
