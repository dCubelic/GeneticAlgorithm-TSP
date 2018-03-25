//
//  TSP.swift
//  TSP
//
//  Created by dominik on 25/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import Foundation
import UIKit

class TSP: GeneticAlgorithm {
    typealias I = Route
    
    var populationSize: Int
    var mutationChance: Double
    
    var population: [Route] = []
    var isEvolving: Bool = false
    
    var onNewGeneration: ((Route, Int) -> ())?
    var generationNumber: Int = 1
    
    init(with cities: [City], populationSize: Int, mutationChance: Double) {
        self.populationSize = populationSize
        self.mutationChance = mutationChance
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
    
    func selectParent(fromGeneration generation: [Route], withTotalCost totalCost: CGFloat) -> Route? {
        let fitness = CGFloat(Double(arc4random()) / Double(UINT32_MAX))
        
        var currentFitness: CGFloat = 0.0
        var result: Route?
        generation.forEach { (route) in
            if currentFitness <= fitness {
                currentFitness += route.fitness(withTotalCost: totalCost)
                result = route
            }
        }
        
        return result
    }
    
    func crossover(firstParent: Route, secondParent: Route) -> Route {
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
    
    func mutate(child: Route) -> Route {
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
