//
//  SegueIdentifier.swift
//  FootballGather
//
//  Created by Radu Dan on 23/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

enum Storyboard: String {
    case main = "Main"
    
    static var defaultStoryboard: UIStoryboard {
        return UIStoryboard(name: Storyboard.main.rawValue, bundle: nil)
    }
}

extension UIStoryboard {
    func instantiateViewController<T>(withIdentifier identifier: String = String(describing: T.self)) -> T {
        return instantiateViewController(withIdentifier: identifier) as! T
    }
}
