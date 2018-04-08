//
//  City.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

struct Grad: Equatable {
    
    let lokacija: CGPoint
    
    init(location: CGPoint) {
        self.lokacija = location
    }
    
    static func ==(lhs: Grad, rhs: Grad) -> Bool {
        return lhs.lokacija == rhs.lokacija
    }
    
    func udaljenost(do grad: Grad) -> CGFloat {
        return sqrt(pow(grad.lokacija.x - lokacija.x, 2) + pow(grad.lokacija.y - lokacija.y, 2))
    }
}
