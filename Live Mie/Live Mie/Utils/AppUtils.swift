//
//  AppUtils.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/20/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import UIKit

class AppUtils {
    class func showHomeView(controller: UIViewController?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ar_vc") as? ARViewController {
            if let controller = controller {
                controller.present(vc, animated: true, completion: nil)
            }else {
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = vc
            }
        }
    }
    
    class func showLoginView(controller: UIViewController?) {
        let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "login_vc") as? LoginViewController {
            if let controller = controller {
                controller.present(vc, animated: true, completion: nil)
            }else {
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = vc
            }
        }
    }
    
    class func showStatusListView(controller: UIViewController?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "status_list_vc") as? StatusListViewController {
            if let controller = controller {
                controller.present(vc, animated: true, completion: nil)
            }else {
                (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController = vc
            }
        }
    }        
}
