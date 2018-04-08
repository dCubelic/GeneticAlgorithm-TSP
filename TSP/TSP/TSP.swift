//
//  TSP.swift
//  TSP
//
//  Created by dominik on 25/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

class TSP: GenetskiAlgoritam {
    typealias I = Ruta
    
    var veličinaPopulacije: Int
    var vjerojatnostMutacije: Double
    
    var populacija: [Ruta] = []
    var evoluira: Bool = false
    
    var onNewGeneration: ((Ruta, Int) -> ())?
    var brojGeneracije: Int = 1
    
    init(with gradovi: [Grad], veličinaPopulacije: Int, vjerojatnostMutacije: Double) {
        self.veličinaPopulacije = veličinaPopulacije
        self.vjerojatnostMutacije = vjerojatnostMutacije
        self.populacija = nasumičnaPopulacija(s: gradovi)
    }
    
    private func nasumičnaPopulacija(s gradovi: [Grad]) -> [Ruta] {
        var populacija: [Ruta] = []
        
        for _ in 0..<veličinaPopulacije {
            populacija.append(Ruta(gradovi: pomiješajGradove(gradovi)))
        }
        
        return populacija
    }
    
    private func pomiješajGradove(_ gradovi: [Grad]) -> [Grad] {
        return gradovi.sorted(by: { _,_ in arc4random() < arc4random() })
    }
    
    func odaberiRoditelja(izGeneracije generacija: [Ruta], sUkupnomTežinom ukupnaTežina: CGFloat) -> Ruta? {
        let dobrota = CGFloat(Double(arc4random()) / Double(UINT32_MAX))
        
        var trenutnaDobrota: CGFloat = 0.0
        var rezultat: Ruta?
        generacija.forEach { (ruta) in
            if trenutnaDobrota <= dobrota {
                trenutnaDobrota += ruta.dobrota(sUkupnomTežinom: ukupnaTežina)
                rezultat = ruta
            }
        }
        
        return rezultat
    }
    
    func križanje(prviRoditelj: Ruta, drugiRoditelj: Ruta) -> Ruta {
        let odsječak: Int = Int(arc4random_uniform(UInt32(prviRoditelj.gradovi.count)))
        var gradovi: [Grad] = Array(prviRoditelj.gradovi[0..<odsječak])
        
        var indeks = odsječak
        while gradovi.count < drugiRoditelj.gradovi.count {
            let grad = drugiRoditelj.gradovi[indeks]
            if !gradovi.contains(grad) {
                gradovi.append(grad)
            }
            indeks = (indeks + 1) % drugiRoditelj.gradovi.count
        }
        
        return Ruta(gradovi: gradovi)
    }
    
    func mutiraj(dijete: Ruta) -> Ruta {
        if vjerojatnostMutacije >= Double(Double(arc4random()) / Double(UINT32_MAX)) {
            let prviIndeks = Int(arc4random_uniform(UInt32(dijete.gradovi.count)))
            let drugiIndeks = Int(arc4random_uniform(UInt32(dijete.gradovi.count)))
            var gradovi = dijete.gradovi
            gradovi.swapAt(prviIndeks, drugiIndeks)
            
            return Ruta(gradovi: gradovi)
        }
        
        return dijete
    }
}
