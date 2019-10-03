//
//  LoginViewController.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/18/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {
    
    // MARK: Constants
    
    // MARK: IBOutlets
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tfEmail: CCTextField!
    @IBOutlet weak var tfPassword: CCTextField!
    @IBOutlet weak var tfForgotPassword: UITextField!
    
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
        return true
    }
    
    func login() {
        let email = tfEmail.text!
        let password = tfPassword.text!
        DialogUtil.showProgress()
        FIRAuthHelper.login(email: email, password: password, success: { (result) in
            DialogUtil.hideProgress()
            self.userLoggedInSuccessfully()
        }) { (message) in
            DialogUtil.hideProgress()
            ToastUtil.show(message: message ?? "Unable to login")
        }
    }
    
    func showForgotPasswordAlert() {
        let alert = UIAlertController(title: "Forgot Password", message: "Enter your email address to receive link for password reset.", preferredStyle: .alert)
        
        alert.addTextField { (field) in
            field.placeholder = "Email"
            self.tfForgotPassword = field
        }
        
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action) in
            if self.tfForgotPassword != nil {
                let text = self.tfForgotPassword.text!
                if !text.isEmpty && ValidationUtil.isValidEmail(testStr: text) {
                    self.sendResetPasswordLink(email: text)
                }else {
                    ToastUtil.show(message: "Invalid Email")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendResetPasswordLink(email: String) {
        DialogUtil.showProgress()
        FIRAuthHelper.resetPassword(email: email, success: {
            DialogUtil.hideProgress()
            DialogUtil.showMessage(title: "Email Sent", message: "Link has been sent to your given email address to reset you password.", controller: self, okHandler: nil)
        }) { (message) in
            DialogUtil.hideProgress()
            ToastUtil.show(message: message ?? "Unable to send reset password link", duration: .long)
        }
    }
    
    func userLoggedInSuccessfully() {
        LocationUtil.shared.requestPermission()
        AppUtils.showHomeView(controller: nil)
        LocationHelper.shared.begin()
    }
    
    
    // MARK: IBActions
    @IBAction func onLoginClick(_ sender: Any) {
        if isValidData() {
            login()
        }
    }
    
    @IBAction func onForgotPassowrd(_ sender: Any) {
        showForgotPasswordAlert()
    }
    
    
}
