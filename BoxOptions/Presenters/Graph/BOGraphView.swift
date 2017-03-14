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
    
    var scale:CGFloat = 1

    var accuracy: Int?
    
    var changes:[BORate]?
    
    let heightSeconds = 30.0
    
    var widthPrice:Double?
    
    var lastTime: Double?
    
    var lastX: Double?
    var lastXCoord: CGFloat?
    
    let maxCornerRadius: CGFloat = 6.0
    
    var dashLinesValueStep: Double?

    var context: CGContext?
    
    
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


        
        context=UIGraphicsGetCurrentContext()
        

        if(flagLandscape) {
        context?.translateBy(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        context?.rotate(by: -CGFloat(M_PI_2))

            context?.translateBy(x:  -self.bounds.size.height/2, y: -self.bounds.size.width/2)
        }
        
        
        let baseSpace=CGColorSpaceCreateDeviceRGB()
        
        drawDashedLines()
        
        
        if(mode == .light) {
            context!.setStrokeColor(UIColor(red: 13.0/255, green: 167.0/255 ,blue: 252.0/255, alpha: 1).cgColor)
            
        }
        else {
            context!.setStrokeColor(UIColor.yellow.cgColor)
        }
        context?.setLineWidth(1)
        context?.setLineJoin(.round)
        context?.setLineCap(.round)
        let lastRate = changes!.last

        let rrr = self.bounds

        if(lastX == nil) {
            lastX = (lastRate!.ask + lastRate!.bid)/2
            
            lastXCoord = self.bounds.size.width/2
            if(flagLandscape) {
                lastXCoord = self.bounds.size.height/2

            }
            
        }

        

        
        var prevX = priceToX(price: (lastRate!.ask + lastRate!.bid)/2)

        var origPoint = CGPoint(x: prevX, y: self.bounds.size.height - 10)
        if(flagLandscape) {
            origPoint = CGPoint(x: prevX, y: self.bounds.size.width - 10)
        }
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
        
        context?.move(to: CGPoint(x: 0, y: origPoint.y))
        context?.setLineWidth(0.5)
        context?.addLine(to: CGPoint(x: self.bounds.size.width, y: origPoint.y))
        context?.strokePath()

        
        if(mode == .light) {
            context!.setFillColor(UIColor(red: 13.0/255, green: 167.0/255 ,blue: 252.0/255, alpha: 1).cgColor)
            
        }
        else {
            context!.setFillColor(UIColor.yellow.cgColor)
        }

        context?.clear(CGRect(x: origPoint.x - 4, y: origPoint.y - 4, width: 8, height: 30))
        context?.fillEllipse(in: CGRect(x: origPoint.x - 3, y: origPoint.y - 3, width: 6, height: 6))
        
        drawRatesLabels()

        if(lastXCoord != self.bounds.size.width) {
            
            let rrr = (changes!.last!.ask + changes!.last!.bid) / 2
            let delta = ((changes!.last!.ask + changes!.last!.bid)/2 - lastX!) / 10.0
            
//            lastXCoord = priceToX(price: lastX! + delta)
            lastX = lastX! + delta
        }

    }
    
    func priceToX(price: Double) -> CGFloat {
        let diff = price - lastX!
        
        var x = lastXCoord! + (CGFloat(diff)*(self.bounds.size.width/CGFloat(widthPrice! / Double(scale)))) + scrollOffset
        if(flagLandscape) {
            x = lastXCoord! + (CGFloat(diff)*(self.bounds.size.height/CGFloat(widthPrice! / Double(scale)))) - scrollOffset
        }
        
        
        
        return x
    }
    
    func xToPrice(x: CGFloat) -> Double {
        
        var diff = (x - scrollOffset - lastXCoord!) / (self.bounds.size.width/CGFloat(widthPrice! / Double(scale)))
        if(flagLandscape) {
            diff = (lastXCoord! - (x - scrollOffset)) / (self.bounds.size.height/CGFloat(widthPrice! / Double(scale)))
        }
        return Double(diff) + lastX!
    }
    
    func timeToY(time: TimeInterval) -> CGFloat {

        var y = self.bounds.size.height - 10 - CGFloat(lastTime! - time)*(self.bounds.size.height/CGFloat(heightSeconds / Double(scale)))
        if(flagLandscape) {
            y = self.bounds.size.width - 10 - CGFloat(lastTime! - time)*(self.bounds.size.width/CGFloat(heightSeconds / Double(scale)))
        }
        return y
    }
    
    func drawDashedLines() {
        
        if(lastX == nil) {
            return
        }
        if(dashLinesValueStep == nil) {
            let xxx = changes?.last?.ask
            let xx2 = changes?.last?.bid
            dashLinesValueStep = (changes!.last!.ask - changes!.last!.bid) / 1.5
        }
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineDash(phase: 0, lengths: [5,5])
        let startPrice = xToPrice(x: 0)
        let firstLineOffsetValue = startPrice.truncatingRemainder(dividingBy: dashLinesValueStep!)
        var value = startPrice - firstLineOffsetValue
        
        let width = priceToX(price: startPrice + dashLinesValueStep!) - priceToX(price: startPrice)
        if(width == 0) {
            return
        }
        repeat {
            let x = priceToX(price: value)
            if(x > self.bounds.size.width+width) {
                break
            }
            context?.move(to: CGPoint(x: x, y: 20))
            context?.addLine(to: CGPoint(x: x, y: self.bounds.size.height-10))
            value += dashLinesValueStep!


        } while(true)
        
        context?.strokePath()
        
        context?.setLineDash(phase: 0, lengths: [])
        
        
    }
    
    func drawRatesLabels() {
        
        if(dashLinesValueStep == nil) {
            return
        }
        context?.clear(CGRect(x: 0, y: -1, width: self.bounds.size.width, height: 20))
        context?.setLineWidth(0.5)
        context?.setStrokeColor(UIColor(red: 207.0/255, green: 210.0/255, blue: 215.0/255, alpha: 1).cgColor)
        context?.move(to: CGPoint(x: 0, y: 20))
        context?.addLine(to: CGPoint(x: self.bounds.size.width, y: 20))
        context?.strokePath()
        let startPrice = xToPrice(x: 0)
        let firstLineOffsetValue = startPrice.truncatingRemainder(dividingBy: dashLinesValueStep!)
        var value = startPrice - firstLineOffsetValue
        
        let width = priceToX(price: startPrice + dashLinesValueStep!) - priceToX(price: startPrice)
        if(width == 0) {
            return
        }

        repeat {
            let x = priceToX(price: value)
            if(x > self.bounds.size.width+width) {
                break
            }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 10)!, NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black]
            
            let formatString = "%." + String(accuracy!) + "f"
            let string = String(format:formatString, value)
            string.draw(with: CGRect(x: x - width/2, y: 0, width: width, height: 20), options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
            
            value += dashLinesValueStep!
            
            
        } while(true)
        
        
    }

    
    
}
