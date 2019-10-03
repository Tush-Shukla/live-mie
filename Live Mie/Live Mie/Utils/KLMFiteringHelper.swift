//
//  KLMFilteringHelper.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/20/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation
import CoreLocation

class KLMFilteringHelper {    
    private var algo: HCKalmanAlgorithm!
    
    init(initialLocation: CLLocation) {
        algo = HCKalmanAlgorithm(initialLocation: initialLocation)
        algo.rValue = 29.0
    }
    
    func filterLocation(location: CLLocation)  -> CLLocation {
        let kalmanLocation = algo.processState(currentLocation: location)
        return kalmanLocation
    }
    
    func resetFilter(newLocation: CLLocation) {
        algo.resetKalman(newStartLocation: newLocation)        
    }
    
}
