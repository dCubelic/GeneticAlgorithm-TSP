//
//  Route.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

class Ruta: Jedinka {
    
    let gradovi: [Grad]
    
    private var duljina: CGFloat?

    init(gradovi: [Grad]) {
        self.gradovi = gradovi
    }
    
    func težina() -> CGFloat {
        if let duljina = self.duljina {
            return duljina
        }
        
        var duljina: CGFloat = 0
        var prošliGrad: Grad?
        
        for grad in gradovi {
            if let prošliGrad = prošliGrad {
                duljina += prošliGrad.udaljenost(do: grad)
            }
            prošliGrad = grad
        }
        
        if let prviGrad = gradovi.first, let zadnjiGrad = gradovi.last {
            duljina += zadnjiGrad.udaljenost(do: prviGrad)
        }
        
        self.duljina = duljina
        
        return duljina
    }
}
