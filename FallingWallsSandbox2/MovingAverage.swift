//
//  MovingAverage.swift
//  FallingWallsSandbox2
//
//  Created by Sam Sulaimanov on 26/08/15.
//  Copyright (c) 2015 ethz. All rights reserved.
//

import Foundation

class MovingAverage {
    var samples: Array<Double>
    var sampleCount = 0
    var period = 5
    
    init(period: Int = 5) {
        self.period = period
        samples = Array<Double>()
    }
    
    var average: Double {
        let sum: Double = samples.reduce(0, combine: +)
        
        if period > samples.count {
            return sum / Double(samples.count)
        } else {
            return sum / Double(period)
        }
    }
    
    func addSample(value: Double) -> Double {
        var pos = Int(fmodf(Float(sampleCount++), Float(period)))
        
        if pos >= samples.count {
            samples.append(value)
        } else {
            samples[pos] = value
        }
        
        return average
    }
}