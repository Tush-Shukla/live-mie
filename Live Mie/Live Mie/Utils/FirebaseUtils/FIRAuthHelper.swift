//
//  FIRAuthHelper.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/19/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import FirebaseAuth



class FIRAuthHelper {
    static func register(email: String, password: String,
                         success: @escaping (_ result: AuthDataResult)->Void,
                         failure: @escaping (_ message: String? )->Void  ) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let err = error {
                return failure(err.localizedDescription)
            }
            if let res = result {
                success(res)
            }
        }
    }
    
    static func login(email: String, password: String,
                      success: @escaping (_ result: AuthDataResult)->Void,
                      failure: @escaping (_ message: String? )->Void  ) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let err = error {
                return failure(err.localizedDescription)
            }
            if let res = result {
                if let user = getUser() {
                    PreferenceUtil.save(user: user)
                }
                return success(res)
            }
        }
    }
    
    static func resetPassword(email: String,
                      success: @escaping ()->Void,
                      failure: @escaping (_ message: String? )->Void  ) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let err = error {
                return failure(err.localizedDescription)
            }
            return success()
        }
    }
    
    static func getUser() -> User? {
        let user = PreferenceUtil.getUser()
        if let fUser = Auth.auth().currentUser  {
            user._id = fUser.uid
            user.email = fUser.email
            return user
        }
        return nil
    }
    
    static func signout(success: @escaping ()->Void,
                        failure: @escaping (_ message: String? )->Void) {
        do {
            try Auth.auth().signOut()
            success()
        } catch let e as NSError  {
            failure(e.localizedDescription)
            print(e.localizedDescription)
        }
    }
}
