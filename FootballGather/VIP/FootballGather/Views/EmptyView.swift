//
//  EmptyView.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 24/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

protocol EmptyViewDelegate: AnyObject {
    func retryAction()
}

class EmptyView: UIView {
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    
    weak var delegate: EmptyViewDelegate?
    
    static func initToView(_ view: UIView, infoText: String) -> EmptyView {
        guard let emptyView: EmptyView = UIView.instanceFromNib() else {
            fatalError("Unable to allocate Empty View")
        }
        
        emptyView.infoLabel.text = infoText
        emptyView.isHidden = true
        emptyView.center = view.center
        view.addSubview(emptyView)
        
        return emptyView
    }
    
    @IBAction func onRetryAction(_ sender: Any) {
        delegate?.retryAction()
    }
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
}
