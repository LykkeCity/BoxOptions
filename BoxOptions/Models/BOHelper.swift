//
//  BOHelper.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 20/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation


let normalDensity = [0.5000,
    0.5398,
    0.5793,
    0.6179,
    0.6554,
    0.6915,
    0.7257,
    0.7580,
    0.7881,
    0.8159,
    0.8413,
    0.8643,
    0.8849,
    0.9032,
    0.9192,
    0.9332,
    0.9452,
    0.9554,
    0.9641,
    0.9713,
    0.9772,
    0.9821,
    0.9861,
    0.9893,
    0.9918,
    0.9938,
    0.9953,
    0.9965,
    0.9974,
    0.9981,
    0.9987,
    0.9990,
    0.9993,
    0.9995,
    0.9997,
    0.9998,
    0.9998,
    0.9999,
    0.9999,
    1.0000
]



class BOHelper {
    
    class func chanceToWinFor(start: Double, end: Double, timeFromNow: Double, history: [BORate]) -> Double {
        
        
        var middleVarianceSum = 0.0
        
        var max = 0.0
        var min = Double(MAXFLOAT)
        var prevRate = history.first
        for rate in history {
            if(rate == history.first) {
                continue
            }
            let val = (rate.ask + rate.bid)/2
            middleVarianceSum += (val - (prevRate!.ask + prevRate!.bid)/2) * (val - (prevRate!.ask + prevRate!.bid)/2)
            
            if(max < val) {
                max = val
            }
            if(min > val) {
                min = val
            }
            
            prevRate = rate
            
        }
        
        let maxVariance = max - min
        let varianceMin = sqrt(middleVarianceSum / Double(history.count - 1))
        
        let price = (history.last!.ask + history.last!.bid)/2
        
        
        let varienceDesired = (timeFromNow / (history.last!.timestamp - history.first!.timestamp)) * maxVariance
        
        var variance = varienceDesired
        if(variance < varianceMin) {
            variance = varianceMin
        }
        
        
        let vvv = BOHelper.normalVarienceFrom(value: fabs(end - price)/variance) - normalVarienceFrom(value: fabs(start - price)/variance)
        
        return fabs(1.0 - vvv)
        
    }
    
    class func normalVarienceFrom(value: Double) -> Double {
        var result:Double?
        var current = 0.0
        for v in normalDensity {
            if(value < current) {
                break
            }
            current += 0.1
            result = v
        }
        
        return result!
        
    }
    
    
}








