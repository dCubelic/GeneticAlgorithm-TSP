//
//  GeneticAlgorithm.swift
//  TSP
//
//  Created by dominik on 18/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

protocol Individual {
    func cost() -> CGFloat
    func fitness(withTotalCost totalCost: CGFloat) -> CGFloat
}

extension Individual {
    func fitness(withTotalCost totalCost: CGFloat) -> CGFloat {
        return 1 - (cost() / totalCost)
    }
}

protocol GeneticAlgorithm {
    associatedtype I: Individual

    var populationSize: Int { get set }
    var mutationChance: Double { get set }
    var population: [I] { get set }
    
    var isEvolving: Bool { get set }
    
    var onNewGeneration: ((I, Int) -> ())? { get set }
    var generationNumber: Int { get set }
    
    func selectParent(fromGeneration generation: [I], withTotalCost totalCost: CGFloat) -> I?
    func crossover(firstParent: I, secondParent: I) -> I
    func mutate(child: I) -> I
}

extension GeneticAlgorithm {
    
    mutating func start() {
        isEvolving = true
        
        while isEvolving {
            let totalPopulationCost = self.population.reduce(0.0, { (result, individual) -> CGFloat in
                return result + individual.cost()
            })

            let fitnessComparator: (I, I) -> Bool = { $0.fitness(withTotalCost: totalPopulationCost) > $1.fitness(withTotalCost: totalPopulationCost) }
            let generation = self.population.sorted(by: fitnessComparator)
            
            var nextGeneration: [I] = []
            
            for _ in 0..<self.populationSize {
                guard
                    let firstParent = self.selectParent(fromGeneration: generation, withTotalCost: totalPopulationCost),
                    let secondParent = self.selectParent(fromGeneration: generation, withTotalCost: totalPopulationCost)
                    else { continue }
                
                let child = self.crossover(firstParent: firstParent, secondParent: secondParent)
                let mutatedChild = self.mutate(child: child)
                
                nextGeneration.append(mutatedChild)
            }
            self.population = nextGeneration
            
            if let bestIndividual = self.population.min(by: fitnessComparator) {
                self.onNewGeneration?(bestIndividual, self.generationNumber)
            }
            
            self.generationNumber += 1
        }
    }
    
    mutating func stop() {
        isEvolving = false
    }
}
