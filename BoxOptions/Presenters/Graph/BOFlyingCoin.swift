//
//  BOFlyingCoin.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class BOFlyingCoin: UIView {
    
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    
    var timer: Timer?
    
    var centerPoint: CGPoint?
    var gamma1: Double?
    var gamma2: Double?
    
    var gamma: Double?
    
    var deltaGamma: Double = 0
    
    var radius:CGFloat = 0
    
    var counter:Int?

    
    func calcValues() {
        
        let point1 = startPoint!
        let point2 = endPoint!
        
        
        let l = sqrt((point1.x - point2.x)*(point1.x - point2.x) + (point1.y - point2.y)*(point1.y - point2.y))
        
        radius = l * 1.5
        
        let alpha = atan(Double((point1.y - point2.y)/(point1.x - point2.x)))
        
        let beta = acos((l/2)/radius)
        
        gamma1 = (M_PI/2 - alpha) - (M_PI/2 - Double(beta))
        
        gamma2 = (M_PI/2 - alpha) + (M_PI/2 - Double(beta))
        
        deltaGamma = (gamma2! - gamma1!)/50
        
        
        let c = CGPoint(x: Double(point1.x) - cos(gamma1!)*Double(radius), y: Double(point1.y) + sin(gamma1!)*Double(radius))
        
        centerPoint = c
//        self.removeFromSuperview()
//        UIApplication.shared.keyWindow?.addSubview(self)
//        self.center = CGPoint(x: c.x + CGFloat(cos(gamma1!))*radius, y: c.y - CGFloat(sin(gamma1!))*radius)
        
 
    }
    
    func startAnimation() {
        gamma = gamma1
        counter = 0
        
        timer = Timer.init(timeInterval: 0.03, target: self, selector: #selector(flyTimerFired), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func flyTimerFired() {
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if(counter == nil) {
            return
        }
        gamma = gamma! + deltaGamma
        let point = CGPoint(x: centerPoint!.x + CGFloat(cos(gamma!))*radius, y: centerPoint!.y - CGFloat(sin(gamma!))*radius)
        counter! += 1
//        if(gamma! > gamma2!) {
//            self.removeFromSuperview()
//        }
        
        let context=UIGraphicsGetCurrentContext()

        context?.setFillColor(UIColor.yellow.cgColor)
        context?.fillEllipse(in: CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20))
        
        context?.move(to: point)
        
        var al = 1.0
        var deltaAl = 1.0/20
        var curAng = gamma!
        let delta = (gamma2! - gamma1!)/40
        for i in 0..<20 {
            al = al - deltaAl
            curAng -= delta
            

            
            context?.setStrokeColor(UIColor.yellow.withAlphaComponent(CGFloat(al)).cgColor)
            let nextPoint = CGPoint(x: centerPoint!.x + CGFloat(cos(curAng))*radius, y: centerPoint!.y - CGFloat(sin(curAng))*radius)
            context?.addLine(to: nextPoint)
            context?.strokePath()
            context?.move(to: nextPoint)
        }
        
        if(curAng > gamma2!) {
            timer?.invalidate()
            self.removeFromSuperview()
            
        }

        


    }
    
    
}
