//
//  Route.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

class Route {
    
    let cities: [City]
    
    private var length: CGFloat?

    init(cities: [City]) {
        self.cities = cities
    }
    
    func routeLength() -> CGFloat {
        if let length = self.length {
            return length
        }
        
        var length: CGFloat = 0
        var previousCity: City?
        
        for city in cities {
            if let previousCity = previousCity {
                length += previousCity.distance(to: city)
            }
            previousCity = city
        }
        
        if let firstCity = cities.first, let lastCity = cities.last {
            length += lastCity.distance(to: firstCity)
        }
        
        self.length = length
        
        return length
    }
    
    func fitness(withTotalLength totalLength: CGFloat) -> CGFloat {
        return 1 - (routeLength() / totalLength)
    }
}
