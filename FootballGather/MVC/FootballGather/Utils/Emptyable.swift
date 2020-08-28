//
//  Emptyable.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 24/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

protocol Emptyable {
    var emptyView: EmptyView { get }
    
    func showEmptyView()
    func hideEmptyView()
}

typealias EmptyViewable = Emptyable & EmptyViewDelegate
