//
//  Loadable.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 08/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

protocol Loadable {
    var loadingView: LoadingView { get }
    
    func showLoadingView()
    func hideLoadingView()
}

extension Loadable where Self: UIViewController {    
    func showLoadingView() {
        view.isUserInteractionEnabled = false
        loadingView.show()
    }
    
    func hideLoadingView() {
        view.isUserInteractionEnabled = true
        view.endEditing(true)
        loadingView.hide()
    }
}

extension Loadable where Self: UIView {
    func showLoadingView() {
        isUserInteractionEnabled = false
        loadingView.show()
    }
    
    func hideLoadingView() {
        isUserInteractionEnabled = true
        endEditing(true)
        loadingView.hide()
    }
}
