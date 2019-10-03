//
//  StatusARView.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/30/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit

class StatusARView: UIView {

    @IBOutlet weak var tvName: UILabel!
    @IBOutlet weak var tvStatus: UILabel!
    
    static func fromNib() -> StatusARView {
        let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)!.first as! StatusARView
        view.frame.size = CGSize(width: 340, height: 80)
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 12
        backgroundColor = UIColor.white.withAlphaComponent(0.85)
    }
    
    func set(name: String, status: String) {
        tvName.text = name
        tvStatus.text = status
        layoutIfNeeded()
    }

}
