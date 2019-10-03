//
//  RegisterViewController.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/18/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    // MARK: Constants
    
    // MARK: IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tfName: CCTextField!
    @IBOutlet weak var tfEmail: CCTextField!
    @IBOutlet weak var tfPassword: CCTextField!
    @IBOutlet weak var tfConfirmPassword: CCTextField!
    
    // MARK: Variables
    
    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    override func viewDidLayoutSubviews() {
        UIUtil.createGradientLayer(view: self.backView, colors: [Theme.Colors.PRIMARY, Theme.Colors.ACCENT])
    }
    
    // MARK: Helper Methods
    func initViews() {
        
    }
    
    func isValidData() -> Bool {
        if(tfName.text!.isEmpty) {
            ToastUtil.show(message: "Name is required")
            return false;
        }
        if(tfEmail.text!.isEmpty) {
            ToastUtil.show(message: "Email is required")
            return false;
        }
        if(!ValidationUtil.isValidEmail(testStr: tfEmail.text!)) {
            ToastUtil.show(message: "Invalid Email")
            return false;
        }
        if(tfPassword.text!.isEmpty) {
            ToastUtil.show(message: "Password is required")
            return false;
        }
        if(tfConfirmPassword.text!.isEmpty) {
            ToastUtil.show(message: "Confirm Password is required")
            return false;
        }
        if(tfPassword.text! != tfConfirmPassword.text!) {
            ToastUtil.show(message: "Password doesn't match")
            return false;
        }                
        return true
    }
    
    func register() {
        let email = tfEmail.text!
        let password = tfPassword.text!
        let name = tfName.text!
        
        DialogUtil.showProgress()
        FIRAuthHelper.register(email: email, password: password, success: { (result) in
            FIRDatabaseHelper.shared.updateUserInfo(id: result.user.uid, name: name, success: {
                DialogUtil.hideProgress()
                DialogUtil.showMessage(title: "Success", message: "Account created successfully. Please login into your account.", controller: self, okHandler: {
                    self.dismiss(animated: true, completion: nil)
                })
            }, failure: { (error) in
                DialogUtil.hideProgress()
                ToastUtil.show(message: error ?? "Info update failed")
            })
        }) { (error) in
            DialogUtil.hideProgress()
            ToastUtil.show(message: error ?? "Registration Failed")
        }
    }
    
    // MARK: IBActions
    @IBAction func onBackClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRegisterClick(_ sender: Any) {
        if isValidData() {
            register()
        }
    }
}
