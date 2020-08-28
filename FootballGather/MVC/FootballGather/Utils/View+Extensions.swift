//
//  View+Extensions.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 07/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

extension UIView {
    static func instanceFromNib<T>() -> T? {
        return UINib(nibName: String(describing: T.self), bundle: nil).instantiate(withOwner: nil, options: nil).first as? T
    }
}
