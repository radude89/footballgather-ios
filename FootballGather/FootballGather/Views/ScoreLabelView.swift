//
//  ScoreLabelView.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

final class ScoreLabelView: UIStackView {
    @IBOutlet weak var teamAScoreLabel: UILabel!
    @IBOutlet weak var teamBScoreLabel: UILabel!
    
    private let drawScoreDescription = "0:0"
    private let drawWinnerDescription = "None"
    
    var scoreDescription: String {
        guard let teamAText = teamAScoreLabel.text,
            let teamBText = teamBScoreLabel.text else {
                return drawScoreDescription
        }
        
        return "\(teamAText):\(teamBText)"
    }
    
    var winnerTeamDescription: String {
        guard let teamAText = teamAScoreLabel.text,
            let teamAScore = Int(teamAText),
            let teamBText = teamBScoreLabel.text,
            let teamBScore = Int(teamBText),
            teamAScore != teamBScore else {
                return drawWinnerDescription
        }
        
        if teamAScore > teamBScore {
            return "Team A"
        } else {
            return "Team B"
        }
    }
}
