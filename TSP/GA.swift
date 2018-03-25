//
//  GA.swift
//  TSP
//
//  Created by dominik on 18/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

class GA {
    var populationSize = 500
    let mutationChance: Double = 0.07
    
    let cities: [City]
    var onNewGeneration: ((Route, Int) -> ())?
    
    private var population: [Route] = []
    
    private var isEvolving = false
    private var generationNumber = 1
    
    
    init(with cities: [City]) {
        self.cities = cities
        self.population = randomPopulation(with: cities)
    }
    
    private func randomPopulation(with cities: [City]) -> [Route] {
        var population: [Route] = []
        
        for _ in 0..<populationSize {
            population.append(Route(cities: randomizeCities(cities)))
        }
        
        return population
    }
    
    private func randomizeCities(_ cities: [City]) -> [City] {
        return cities.sorted(by: { _,_ in arc4random() < arc4random() })
    }
    
    func start() {
        isEvolving = true
        
        DispatchQueue.global().async {
            while self.isEvolving {
                
                let totalPopulationLength = self.population.reduce(0.0, { (result, route) -> CGFloat in
                    return result + route.routeLength()
                })
                let fitnessComparator: (Route, Route) -> Bool = { $0.fitness(withTotalLength: totalPopulationLength) > $1.fitness(withTotalLength: totalPopulationLength) }
                let generation = self.population.sorted(by: fitnessComparator)
                
                var nextGeneration: [Route] = []
                
                for _ in 0..<self.populationSize {
                    guard
                        let firstParent = self.selectParent(fromGeneration: generation, withTotalLength: totalPopulationLength),
                        let secondParent = self.selectParent(fromGeneration: generation, withTotalLength: totalPopulationLength)
                        else { continue }
                    
                    let child = self.crossover(firstParent: firstParent, secondParent: secondParent)
                    let mutatedChild = self.mutate(child)
                    
                    nextGeneration.append(mutatedChild)
                }
                self.population = nextGeneration
                
                if let bestRoute = self.population.min(by: fitnessComparator) {
                    self.onNewGeneration?(bestRoute, self.generationNumber)
                }

                self.generationNumber += 1
                
            }
        }
    }
    
    func stop() {
        isEvolving = false
    }
    
    private func selectParent(fromGeneration generation: [Route], withTotalLength totalLength: CGFloat) -> Route? {
        let fitness = CGFloat(Double(arc4random()) / Double(UINT32_MAX))
        
        var currentFitness: CGFloat = 0.0
        var result: Route?
        generation.forEach { (route) in
            if currentFitness <= fitness {
                currentFitness += route.fitness(withTotalLength: totalLength)
                result = route
            }
        }
        
        return result
    }
    
    private func crossover(firstParent: Route, secondParent: Route) -> Route {
        let slice: Int = Int(arc4random_uniform(UInt32(firstParent.cities.count)))
        var cities: [City] = Array(firstParent.cities[0..<slice])
        
        var index = slice
        while cities.count < secondParent.cities.count {
            let city = secondParent.cities[index]
            if !cities.contains(city) {
                cities.append(city)
            }
            index = (index + 1) % secondParent.cities.count
        }
        
        return Route(cities: cities)
    }
    
    private func mutate(_ child: Route) -> Route {
        if mutationChance >= Double(Double(arc4random()) / Double(UINT32_MAX)) {
            let firstIndex = Int(arc4random_uniform(UInt32(child.cities.count)))
            let secondIndex = Int(arc4random_uniform(UInt32(child.cities.count)))
            var cities = child.cities
            cities.swapAt(firstIndex, secondIndex)
            
            return Route(cities: cities)
        }
        
        return child
    }
}
