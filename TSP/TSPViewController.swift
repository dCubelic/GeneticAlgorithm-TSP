//
//  ViewController.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import UIKit

class TSPViewController: UIViewController {
    
    @IBOutlet weak var citiesView: UIView!
    @IBOutlet weak var generationLabel: UILabel!
    @IBOutlet weak var totalLengthLabel: UILabel!
    @IBOutlet weak var populationSlider: UISlider!
    @IBOutlet weak var mutationSlider: UISlider!
    @IBOutlet weak var populationSizeLabel: UILabel!
    @IBOutlet weak var mutationChanceLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    var locations: [CGPoint] = []
    var geneticAlgorithm: TSP?
    
    let cityImageSize = CGSize(width: 30, height: 30)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if citiesView.point(inside: touch.location(in: citiesView), with: event) {
            if geneticAlgorithm?.isEvolving == true {
                stopAction(self)
            }
            let location = touch.location(in: citiesView)
            locations.append(location)
            
            drawCities()
        }
    }
    
    private func drawCities() {
        
        self.citiesView.subviews.forEach( { $0.removeFromSuperview() } )
        self.citiesView.layer.sublayers?.removeAll()
        
        self.locations.forEach { (location) in
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: location.x - cityImageSize.width / 2, y: location.y - cityImageSize.height / 2), size: cityImageSize))
            imageView.image = #imageLiteral(resourceName: "city")
            imageView.tintColor = .white
            self.citiesView.addSubview(imageView)
        }
    }
    
    private func drawRoute(route: Route) {
        guard let firstCity = route.cities.first else { return }
        
        var otherCities = route.cities
        otherCities.remove(at: 0)
        
        drawCities()
        
        DispatchQueue.main.async {
            let path = UIBezierPath()
            UIColor.black.setStroke()
            path.lineWidth = 1
            
            path.move(to: firstCity.location)
            otherCities.forEach { (city) in
                path.addLine(to: city.location)
            }
            path.addLine(to: firstCity.location)
            
            path.stroke()
            
            let pathLayer = CAShapeLayer()
            pathLayer.path = path.cgPath
            pathLayer.fillColor = UIColor.clear.cgColor
            pathLayer.strokeColor = UIColor.yellow.cgColor
            self.citiesView.layer.addSublayer(pathLayer)
        }
    }
    
    @IBAction func populationSliderChanged(_ sender: Any) {
        populationSlider.value = Float(Int(populationSlider.value))
        populationSizeLabel.text = "Population Size: \(populationSlider.value)"
    }
    
    @IBAction func mutationSliderChanged(_ sender: Any) {
        mutationChanceLabel.text = "Mutation Chance: \(mutationSlider.value)"
    }
    
    @IBAction func startAction(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        clearButton.isEnabled = false
        populationSlider.isEnabled = false
        mutationSlider.isEnabled = false
        
        geneticAlgorithm = TSP(with: locations.map { City(location: $0) }, populationSize: Int(populationSlider.value), mutationChance: Double(mutationSlider.value))
        geneticAlgorithm?.onNewGeneration = {
            (route, generation) in
            DispatchQueue.main.async {
                self.generationLabel.text = "Generation: \(generation)"
                self.totalLengthLabel.text = "Total Length: \(route.fitness())"
                self.drawRoute(route: route)
            }
        }
        
        DispatchQueue.global().async {
            self.geneticAlgorithm?.start()
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        clearButton.isEnabled = false
        
        locations.removeAll()
//        citiesView.layer.sublayers?.removeAll()
        
//        citiesView.subviews.forEach( { $0.removeFromSuperview() } )
        self.citiesView.subviews.forEach( { $0.removeFromSuperview() } )
        self.citiesView.layer.sublayers?.removeAll()
        
        generationLabel.text = "Generation: 0"
    }
    
    @IBAction func stopAction(_ sender: Any) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        clearButton.isEnabled = true
        populationSlider.isEnabled = true
        mutationSlider.isEnabled = true
        
        geneticAlgorithm?.stop()
    }
}


