//
//  ViewController.swift
//  TSP
//
//  Created by dominik on 17/03/2018.
//  Copyright © 2018 Dominik Cubelic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if citiesView.point(inside: touch.location(in: citiesView), with: event) {
            let location = touch.location(in: citiesView)
            locations.append(location)
            
            drawCities()
            
        }
    }
    
    private func drawCities() {
        
        self.citiesView.layer.sublayers?.removeAll()
        
        self.locations.forEach { (location) in
            let circle = UIBezierPath.init(arcCenter: location, radius: 5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            let circleLayer = CAShapeLayer()
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = UIColor.red.cgColor
            circleLayer.strokeColor = UIColor.red.cgColor
            self.citiesView.layer.addSublayer(circleLayer)
        }
    }
    
    private func drawRoute(route: Ruta) {
        guard let firstCity = route.gradovi.first else { return }
        
        var otherCities = route.gradovi
        otherCities.remove(at: 0)
        
        drawCities()
        
        DispatchQueue.main.async {
            let path = UIBezierPath()
            UIColor.black.setStroke()
            path.lineWidth = 1
            
            path.move(to: firstCity.lokacija)
            otherCities.forEach { (city) in
                path.addLine(to: city.lokacija)
            }
            path.addLine(to: firstCity.lokacija)
            
            path.stroke()
            
            let pathLayer = CAShapeLayer()
            pathLayer.path = path.cgPath
            pathLayer.fillColor = UIColor.clear.cgColor
            pathLayer.strokeColor = UIColor.black.cgColor
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
        
        geneticAlgorithm = TSP(with: locations.map { Grad(location: $0) }, veličinaPopulacije: Int(populationSlider.value), vjerojatnostMutacije: Double(mutationSlider.value))
        geneticAlgorithm?.onNewGeneration = {
            (route, generation) in
            DispatchQueue.main.async {
                self.generationLabel.text = "Generation: \(generation)"
                self.totalLengthLabel.text = "Total Length: \(route.težina())"
                self.drawRoute(route: route)
            }
        }
        
        DispatchQueue.global().async {
            self.geneticAlgorithm?.pokreni()
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        startButton.isEnabled = true
        stopButton.isEnabled = false
        clearButton.isEnabled = false
        
        locations.removeAll()
        citiesView.layer.sublayers?.removeAll()
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


