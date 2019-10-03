//
//  LocationHelper.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/20/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import UIKit

class LocationHelper {
    
    static var shared = LocationHelper()
    
    private var filter: KLMFilteringHelper! {
        didSet {
            if filter != nil {
                startLocationUpdates()
            }
        }
    }
    
    private init() {
        
    }
    
    func begin() {
        checkAllPermissions()
        initKLMFilter()
    }
    
    private func initKLMFilter() {
        LocationUtil.shared.getLocation(timeout: 3.0, completion: { (location) in
            guard let location = location else {return}
            self.filter = KLMFilteringHelper(initialLocation: location)
        }) {
            Log(message: "Failed to initialize kalman filter")
        }
    }
    
    private func startLocationUpdates() {
        LocationUtil.shared.subscribeToContinuousLocationUpdates(completion: { (location) in
            guard let location = location else {return}            
            FIRDatabaseHelper.shared.updateUserLocation(id: FIRAuthHelper.getUser()?._id, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, success: {
                print("Location Sent")
            }, failure: { (message) in
                Log(message: message ?? "Unable to send location")
            })
            let kLocation = self.filter.filterLocation(location: location)
//            print(kLocation.coordinate)
        }) {
            Log(message: "Error getting location")
        }
    }
    
    private func checkAllPermissions() {
        if LocationUtil.shared.hasRequestedPermission() && !LocationUtil.shared.isPermissionGranted() {
            if let vc = AppDelegate.shared.window?.rootViewController {
                DialogUtil.showConfirmationDialog(title: "Enable Permission", message: "Location permission is not granted. Please enable it to access app features", controller: vc, positive: UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                    SystemAppUtil.openAppSettings()
                }), negative: UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
        }else if !LocationUtil.shared.hasRequestedPermission() {
            LocationUtil.shared.requestPermission()
        }
    }
    
    private func end() {
        LocationUtil.shared.unsubscribeToContinuousLocationUpdates()
    }
}
