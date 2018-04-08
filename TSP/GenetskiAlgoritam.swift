//
//  GeneticAlgorithm.swift
//  TSP
//
//  Created by dominik on 18/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

protocol Jedinka {
    func težina() -> CGFloat
    func dobrota(sUkupnomTežinom ukupnaTežina: CGFloat) -> CGFloat
}

extension Jedinka {
    func dobrota(sUkupnomTežinom ukupnaTežina: CGFloat) -> CGFloat {
        return 1 - (težina() / ukupnaTežina)
    }
}

protocol GenetskiAlgoritam {
    associatedtype I: Jedinka

    var veličinaPopulacije: Int { get set }
    var vjerojatnostMutacije: Double { get set }
    var populacija: [I] { get set }
    
    var evoluira: Bool { get set }
    
    var onNewGeneration: ((I, Int) -> ())? { get set }
    var brojGeneracije: Int { get set }
    
    func odaberiRoditelja(izGeneracije generation: [I], sUkupnomTežinom ukupnaTežina: CGFloat) -> I?
    func križanje(prviRoditelj: I, drugiRoditelj: I) -> I
    func mutiraj(dijete: I) -> I
}

extension GenetskiAlgoritam {
    
    mutating func pokreni() {
        evoluira = true
        
        while evoluira {
            let ukupnaTežinaPopulacije = self.populacija.reduce(0.0, { (rezultat, jedinka) -> CGFloat in
                return rezultat + jedinka.težina()
            })

            let komparatorDobrote: (I, I) -> Bool = { $0.dobrota(sUkupnomTežinom: ukupnaTežinaPopulacije) > $1.dobrota(sUkupnomTežinom: ukupnaTežinaPopulacije) }
            let generacija = self.populacija.sorted(by: komparatorDobrote)
            
            var novaGeneracija: [I] = []
            
            for _ in 0..<self.veličinaPopulacije {
                guard
                    let prviRoditelj = self.odaberiRoditelja(izGeneracije: generacija, sUkupnomTežinom: ukupnaTežinaPopulacije),
                    let drugiRoditelj = self.odaberiRoditelja(izGeneracije: generacija, sUkupnomTežinom: ukupnaTežinaPopulacije)
                    else { continue }
                
                let dijete = self.križanje(prviRoditelj: prviRoditelj, drugiRoditelj: drugiRoditelj)
                let mutiranoDijete = self.mutiraj(dijete: dijete)
                
                novaGeneracija.append(mutiranoDijete)
            }
            self.populacija = novaGeneracija
            
            if let najboljaJedinka = self.populacija.min(by: komparatorDobrote) {
                self.onNewGeneration?(najboljaJedinka, self.brojGeneracije)
            }
            
            self.brojGeneracije += 1
        }
    }
    
    mutating func stop() {
        evoluira = false
    }
}
