//
//  BOFlyingCoin.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class BOFlyingCoin: UIView, CAAnimationDelegate {
    
    dynamic var progress: CGFloat = 0.00 {
        didSet {
            circleLayer().counter = 0
            let animation = CABasicAnimation()
            animation.keyPath = "progress"
            animation.fromValue = circleLayer().progress
            animation.toValue = progress
            animation.duration = Double(3)
            animation.delegate = self
            
            let yyy = circleLayer()
            
            

            self.layer.add(animation, forKey: "progress")
            circleLayer().progress = progress
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if(circleLayer().presenter != nil) {
            circleLayer().presenter!.balance += circleLayer().value!
        }

        self.removeFromSuperview()
    }

    func startAnimation() {
        
        let yyy = self.circleLayer()
        self.circleLayer().gamma = self.circleLayer().gamma1
        self.progress = 100
    }
    
    func circleLayer() ->  BOFlyingCoinLayer {
        return self.layer as! BOFlyingCoinLayer
    }
    
    override class var layerClass: AnyClass {
        return BOFlyingCoinLayer.self
    }
    
}

class BOFlyingCoinLayer: CALayer {
    
    @NSManaged var progress: CGFloat
    
//    dynamic var progress: CGFloat = 0.0

    
    weak var presenter: BOGamePresenter?
    
    var value: Double?
    
    var startPoint: CGPoint?
    var endPoint: CGPoint?
    
    var timer: Timer?
    
    var centerPoint: CGPoint?
    var gamma1: Double?
    var gamma2: Double?
    
    var gamma: Double?
    
    var deltaGamma: Double = 0
    
    var radius:CGFloat = 0
    
    var counter:CGFloat?

    
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
    
    override init() {
        super.init()
    }
    
    override init(layer: Any) {
        let l = layer as? BOFlyingCoinLayer
        value = l?.value
        startPoint = l?.startPoint
        endPoint = l?.endPoint
        centerPoint = l?.centerPoint
        gamma1 = l?.gamma1
        gamma2 = l?.gamma2
        gamma = l?.gamma
        deltaGamma = (l?.deltaGamma)!
        radius = (l?.radius)!
        
        super.init(layer: layer)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == "progress" {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    
    override func draw(in ctx: CGContext) {
        
        super.draw(in: ctx)
        
        print("Called draw")
        
        
        
        UIGraphicsPushContext(ctx)

        if(gamma == nil) {
            return
        }
        counter = progress
        
        print(counter)
        gamma = gamma1! + Double(counter!) * deltaGamma
        let point = CGPoint(x: centerPoint!.x + CGFloat(cos(gamma!))*radius, y: centerPoint!.y - CGFloat(sin(gamma!))*radius)
//        counter! += 1
        
//        let context=UIGraphicsGetCurrentContext()
        var context: CGContext?
        context = ctx
        
        
        context?.setFillColor(UIColor.yellow.cgColor)
        context?.fillEllipse(in: CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20))
        
        context?.move(to: point)
        
        var al = 1.0
        var deltaAl = 1.0/10
        var curAng = gamma!
        let delta = (gamma2! - gamma1!)/20
        for i in 0..<10 {
            al = al - deltaAl
            curAng -= delta
            
            
            
            context?.setStrokeColor(UIColor.yellow.withAlphaComponent(CGFloat(al)).cgColor)
            let nextPoint = CGPoint(x: centerPoint!.x + CGFloat(cos(curAng))*radius, y: centerPoint!.y - CGFloat(sin(curAng))*radius)
            context?.addLine(to: nextPoint)
            context?.strokePath()
            context?.move(to: nextPoint)
        }
        
//        if(curAng > gamma2!) {
////            timer?.invalidate()
////            self.removeFromSuperview()
//            
//            self.removeFromSuperlayer()
//            if(presenter != nil) {
//                presenter!.balance += value!
//            }
//
//        }
        
        UIGraphicsPopContext()


    }
    
    
    
    
    
//    - (id) initWithLayer:(id)layer
//    {
//    self = [super initWithLayer:layer];
//    if (self) {
//    AngledLayer *angledVersion = (AngledLayer *)layer;
//    self.angle = angledVersion.angle;
//    }
//    return self;
//    }
    
    func startAnimation() {
        gamma = gamma1
        counter = 0
        
        let animation = CABasicAnimation()
        animation.keyPath = "progress"
        animation.fromValue = 0
        animation.toValue = 1000
        animation.duration = Double(3)
        self.add(animation, forKey: "progress")
//        self.progress = 1000
        
//        UIView.animate(withDuration: 5, animations: {
//         self.alpha = 0.99
//        })
        
//        timer = Timer.init(timeInterval: 0.03, target: self, selector: #selector(flyTimerFired), userInfo: nil, repeats: true)
//        
//        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func flyTimerFired() {
        self.setNeedsDisplay()
    }
    
//    override func draw(_ rect: CGRect) {
//
//        
//
//
//    }
    
    
}
