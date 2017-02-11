//
//  BOGraphView.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation

import UIKit

class BOGraphView: UIView {
    
    var changes:[BORate]?
    
    let heightSeconds = 30.0
    
    var widthPrice:Double?
    
    var lastTime: Double?
    
    var lastX: Double?
    var lastXCoord: CGFloat?
    
    let maxCornerRadius: CGFloat = 4.0

    
    func calcValues() {
        
        
        
        
        
    }
    
    override func draw(_ rect: CGRect) {
        
//        if(changes!.count < 3) {
//            return
//        }
        

        
        lastTime = Date.timeIntervalSinceReferenceDate
        
//        changes = Array()
//        
//        let r1 = BORate()
//        r1.ask = 51
//        r1.bid = 50
//        r1.timestamp = lastTime! - 30
//        changes?.append(r1)
//        
//        let r2 = BORate()
//        r2.ask = 110
//        r2.bid = 109
//        r2.timestamp = lastTime! - 20
//        changes?.append(r2)
//
//        let r3 = BORate()
//        r3.ask = 150
//        r3.bid = 149
//        r3.timestamp = lastTime! - 10
//        changes?.append(r3)
//
//        let r4 = BORate()
//        r4.ask = 180
//        r4.bid = 179
//        r4.timestamp = lastTime! - 1
//        changes?.append(r4)
//
//        widthPrice = 500


        
        let context=UIGraphicsGetCurrentContext()
        
         
        
        context?.setLineWidth(1)
        
        let baseSpace=CGColorSpaceCreateDeviceRGB()
        
        context!.setStrokeColor(UIColor.yellow.cgColor)
        context?.setLineWidth(2)
        context?.setLineJoin(.round)
        context?.setLineCap(.round)
        let lastRate = changes!.last

        
        if(lastX == nil) {
            lastX = (lastRate!.ask + lastRate!.bid)/2
            lastXCoord = self.bounds.size.width/2
        }

        
        var prevX = priceToX(price: (lastRate!.ask + lastRate!.bid)/2)

        let origPoint = CGPoint(x: prevX, y: self.bounds.size.height - 10)
        context?.move(to: origPoint)
        
        let y = timeToY(time: lastRate!.timestamp)
        

        var prevY = y
        
        
        
        
        for i in stride(from: changes!.count - 2, to: 0, by: -1)
        {
            let rate = changes![i]
            
            
            
            var x = priceToX(price: (rate.ask + rate.bid)/2)
//            x -= 50
            
            let y = timeToY(time: rate.timestamp)
            
            var cornerRadius = maxCornerRadius
            if(cornerRadius > fabs(x - prevX)/2) {
                cornerRadius = fabs(x - prevX)/2
            }
            
//            if(i == changes!.count - 2) {
                context?.addLine(to: CGPoint(x: prevX, y: prevY + cornerRadius))
//            }

            
//            context?.addLine(to: CGPoint(x: prevX, y: y))
            
            var center:CGPoint?
            var startAngle: Double?
            var endAngle: Double?
            if(x > prevX) {
                center = CGPoint(x: prevX + cornerRadius, y: prevY + cornerRadius)
                startAngle = M_PI
                endAngle = 0 - M_PI/2
                context?.addArc(center: center!, radius: cornerRadius, startAngle: CGFloat(startAngle!), endAngle: CGFloat(endAngle!), clockwise: false)

            }
            else {
                center = CGPoint(x: prevX - cornerRadius, y: prevY + cornerRadius)
                startAngle = M_PI * 2
                endAngle = (M_PI * 2) - M_PI/2
                context?.addArc(center: center!, radius: cornerRadius, startAngle: CGFloat(startAngle!), endAngle: CGFloat(endAngle!), clockwise: true)

            }
            
            if(x > prevX) {
                context?.addLine(to: CGPoint(x: x - cornerRadius, y: prevY))
                
                center = CGPoint(x: x - cornerRadius, y: prevY - cornerRadius)
                startAngle = M_PI/2
                endAngle = 0
                context?.addArc(center: center!, radius: cornerRadius, startAngle: CGFloat(startAngle!), endAngle: CGFloat(endAngle!), clockwise: true)
                
            }
            else {
                context?.addLine(to: CGPoint(x: x + cornerRadius, y: prevY))
                
                center = CGPoint(x: x + cornerRadius, y: prevY - cornerRadius)
                startAngle =  M_PI / 2
                endAngle = M_PI
                context?.addArc(center: center!, radius: cornerRadius, startAngle: CGFloat(startAngle!), endAngle: CGFloat(endAngle!), clockwise: false)
                
            }

//            context?.addLine(to: CGPoint(x: x, y: y + cornerRadius))
            
            if(prevY < 0) {
                break
            }

            prevX = x
            prevY = y
        }
        context?.strokePath()
        
        context?.setFillColor(UIColor.yellow.cgColor)
        context?.fillEllipse(in: CGRect(x: origPoint.x - 5, y: origPoint.y - 5, width: 10, height: 10))
        
        if(lastXCoord != self.bounds.size.width) {
            
            let rrr = (changes!.last!.ask + changes!.last!.bid) / 2
            let delta = ((changes!.last!.ask + changes!.last!.bid)/2 - lastX!) / 10.0
            
//            lastXCoord = priceToX(price: lastX! + delta)
            lastX = lastX! + delta
        }

    }
    
    func priceToX(price: Double) -> CGFloat {
        let diff = price - lastX!
        let x = lastXCoord! + (CGFloat(diff)*(self.bounds.size.width/CGFloat(widthPrice!)))

        return x
    }
    
    func xToPrice(x: CGFloat) -> Double {
        let diff = (x - lastXCoord!) / (self.bounds.size.width/CGFloat(widthPrice!))
        return Double(diff) + lastX!
    }
    
    func timeToY(time: TimeInterval) -> CGFloat {

        let y = self.bounds.size.height - 10 - CGFloat(lastTime! - time)*(self.bounds.size.height/CGFloat(heightSeconds))
        return y
    }
    
    
}
