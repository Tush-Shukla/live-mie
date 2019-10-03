//
//  Location.swift
//  Live Mie
//
//  Created by Abdul Wahib on 6/27/19.
//  Copyright © 2019 Nova Storm. All rights reserved.
//

import Foundation

class Location {
    var id: String!
    var latitude: Double!
    var longitude: Double!
    var name: String!
    var status: String!
    
    init(id: String, name: String,status: String,latitude: Double, longitude: Double) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.status = status
    }
            
}
