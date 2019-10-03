//
//  BaseViewController.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/18/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    // MARK: Constants
    
    // MARK: IBOutlets
    
    
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
//        initViews()
    }
    
    // MARK: Helper Methods
//    func initViews() {
//
//    }
    
    
    // MARK: IBActions
    
}

extension BaseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
