//
//  City.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

struct City: Equatable {
    
    let location: CGPoint
    
    init(location: CGPoint) {
        self.location = location
    }
    
    static func ==(lhs: City, rhs: City) -> Bool {
        return lhs.location == rhs.location
    }
    
    func distance(to city: City) -> CGFloat {
        return sqrt(pow(city.location.x - location.x, 2) + pow(city.location.y - location.y, 2))
    }
}
