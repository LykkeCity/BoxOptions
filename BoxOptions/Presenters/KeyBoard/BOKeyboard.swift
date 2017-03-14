//
//  BOKeyboard.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

class BOKeyboardView: UIView {
    
    var keysArray:Array<BOKeyView>?
    
    var maxScrollOffset:CGFloat?
    
    
    weak var presenter: BOGamePresenter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.keysArray == nil) {
            self.keysArray = Array()
            
        }

        var etalon = (self.bounds.size.height/5) * CGFloat(keyboardScale)
        
        
        if(flagLandscape == false) {
            etalon = (self.bounds.size.width/5)  * CGFloat(keyboardScale)
        }
        
        var horNumber = 21.0
        var verNumber = 12.0
        
        maxScrollOffset = etalon * CGFloat(horNumber / 2) * presenter!.graphView!.scale

        
        if(flagLandscape) {
            horNumber = 12.0
            verNumber = 21.0
            
        }
        
        
        
        var value = 1.0


        
            if(flagLandscape) {
                
                let width = etalon * self.presenter!.graphView!.scale
                let height = width
                
                
                
                for i in 0..<Int(horNumber) {
                    for j in 0..<Int(verNumber) {
                        
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        
                        let center = CGPoint(x: (CGFloat(i) + 0.5) * width, y: self.bounds.size.height/2 - (CGFloat(verNumber/2) - CGFloat(j) - 0.5) * height + scrollOffset)
                        
                        value = Double(i)*0.7/keyboardScale + 1.1 + fabs(verNumber/2 - Double(0.5) - Double(j))*1.1/keyboardScale
                        
                        
                        var keyView: BOKeyView?
                        
                        if(self.keysArray!.count < Int(horNumber * verNumber)) {
                            keyView = BOKeyView.init(frame: frame, value: value)
                            keyView!.presenter = self.presenter
                            self.keysArray?.append(keyView!)
                        }
                        else {
                            keyView = self.keysArray![Int(i) * Int(verNumber) + Int(j)]
                        }
                        
                            keyView!.frame = frame
                            keyView!.center = center
                            keyView!.value = value
                            if(keyView!.superview == nil) {
                                self.addSubview(keyView!)
                            }
                        
                        
                        
                        
                    }
                }
            }
                
            else {
                
                let width = etalon * self.presenter!.graphView!.scale
                let height = width
                
                
                
                for i in 0..<Int(horNumber) {
                    for j in 0..<Int(verNumber) {
                        
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        
                        let center = CGPoint(x: self.bounds.size.width/2 - (CGFloat(horNumber/2) - CGFloat(i) - 0.5) * width + scrollOffset, y: (CGFloat(j)+0.5) * height)
                        
                        value = Double(j)*0.7/keyboardScale + 1.1 + fabs(horNumber/2 - Double(0.5) - Double(i))*1.1/keyboardScale
                        
                        
                        var keyView: BOKeyView?
                        
                        if(self.keysArray!.count < Int(horNumber * verNumber)) {
                            keyView = BOKeyView.init(frame: frame, value: value)
                            keyView!.presenter = self.presenter
                            self.keysArray?.append(keyView!)
                        }
                        else {
                            keyView = self.keysArray![Int(i) * Int(verNumber) + Int(j)]
                        }
                        
                            keyView!.frame = frame
                            keyView!.center = center
                            keyView!.value = value
                            if(keyView!.superview == nil) {
                                self.addSubview(keyView!)
                            }
                        
 

                    }
                }
                
            }
        }
        

        
    
    
    
    
}

class BOKeyView: UIView {
    
    weak var presenter: BOGamePresenter?
    private var _value: Double?
    var value:Double? {
        get {
            return _value
        }
        set {
            _value = newValue
            if(label != nil) {
                label?.text = NSString.init(format: "%.2f", _value! * betAmount) as String
                
                self.setNeedsLayout()
            }
        }
    }
    
    var label: UILabel?
    var box:UIView?
    
    init(frame: CGRect, value: Double) {
        super.init(frame: frame)
        
        box = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        box?.isUserInteractionEnabled = false
        self.backgroundColor = nil
        
        label = UILabel()
        label?.font = UIFont(name: "ProximaNova-Regular", size: 14)
        
        if(mode == .light) {
            box!.layer.borderColor = UIColor(red: 230.0/255, green: 230.0/255, blue: 230.0/255, alpha: 1).cgColor
            box!.backgroundColor = UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.9)
            label?.textColor = UIColor(red: 63.0/255, green: 77.0/255, blue: 96.0/255, alpha: 1)

        }
        else {
            box!.layer.borderColor = UIColor(red: 143.0/255, green: 125.0/255, blue: 25.0/255, alpha: 1).cgColor
            box!.backgroundColor = UIColor(red: 11.0/255, green: 3.0/255, blue: 55.0/255, alpha: 1)
            label?.textColor = UIColor(red: 1, green: 246.0/255, blue: 0, alpha: 1)

        }
        box!.layer.borderWidth = 0.5
        
        self.addSubview(box!)
        

        label?.textAlignment = .center
        label?.frame = box!.frame
        label?.adjustsFontSizeToFitWidth = true
        label?.minimumScaleFactor = 0.3
        self.addSubview(label!)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        self.addGestureRecognizer(gesture)
        
        self.value = value
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        label?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let frame = self.frame
        box?.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        label?.frame = box!.frame

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func userTapped() {
        if(presenter!.balance < betAmount) {
            return
        }
        presenter?.balance -= betAmount
//        _ = BOOptionView.init(frame: self.frame, inView:self.superview!.superview!, value: value! * betAmount, presenter: presenter!)
        _ = BOOptionView.init(frame: self.convert(self.bounds, to: self.superview!.superview!), inView:self.superview!.superview!, value: value! * betAmount, presenter: presenter!)
        
        print("TAPPED")
    }
}

class BOOptionView: UIView {
    
    var value:Double?
    weak var presenter: BOGamePresenter?

    weak var graphView: BOGraphView?
    
//    var originalY:CGFloat?
//    var originalX:CGFloat?
    
    var distToGraph: CGFloat?
    var originalTimeStamp: Double?
    var timeNeededToGoToGraph: Double?
    
    var originalWidth:CGFloat?
    var originalHeight:CGFloat?
    
    var price: Double?
    
    var delta:CGFloat?

    var timer: Timer?
    
    var stopped = false
    
    
    init(frame: CGRect, inView: UIView, value: Double, presenter: BOGamePresenter) {
        super.init(frame: frame)
        var index = 0
        if(inView.subviews.count > 0) {
            if(inView.subviews[0] is BOKeyboardView) {
                index = 1
            }
        }
        inView.insertSubview(self, at: index)
        self.clipsToBounds = true
        self.value = value
        
        originalWidth = frame.size.width / presenter.graphView!.scale
        originalHeight = frame.size.height / presenter.graphView!.scale
        
        let label = UILabel()
        label.font = UIFont(name: "ProximaNova-Regular", size: 14)


        if(mode == .light) {
            self.layer.borderColor = UIColor.white.cgColor
            self.backgroundColor = UIColor(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
            label.textColor = UIColor.white

        }
        else {
            self.layer.borderColor = UIColor.brown.cgColor
            self.backgroundColor = UIColor.yellow
            label.textColor = UIColor.black

        }
        self.layer.borderWidth = 0.5
        

        label.backgroundColor = nil
        label.textAlignment = .center
        label.isOpaque = false
        label.text = NSString.init(format: "%.2f", value) as String
        label.minimumScaleFactor = 0.3
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        self.addSubview(label)
        label.frame = self.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        self.presenter = presenter
        graphView = presenter.graphView
        if(flagLandscape) {
            
            let p = graphView!.convert(CGPoint(x: graphView!.bounds.size.width, y: 0), to: self)
            distToGraph = -p.x + frame.size.width/2
        }
        else {
            let p = graphView!.convert(CGPoint(x: 0, y: graphView!.bounds.size.height), to: self)
            distToGraph = -p.y + frame.size.height/2
        }
        
        
//        originalY = frame.origin.y + frame.size.height/2
//        originalX = frame.origin.x + frame.size.width/2
        originalTimeStamp = Date.timeIntervalSinceReferenceDate
        
        
        if(flagLandscape) {
            price = graphView!.xToPrice(x: frame.origin.y + frame.size.height/2)
            
            delta = self.graphView!.bounds.size.width / CGFloat(self.graphView!.heightSeconds  / Double(graphView!.scale))
            
            timeNeededToGoToGraph = Double(distToGraph! / delta!)


        }
        else {
            price = graphView!.xToPrice(x: frame.origin.x + frame.size.width/2)

            delta = self.graphView!.bounds.size.height / CGFloat(self.graphView!.heightSeconds  / Double(graphView!.scale))
            
            timeNeededToGoToGraph = Double(distToGraph! / delta!)

        }
        

        timer = Timer.init(timeInterval: 0.04, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func timerFired () {
        self.setNeedsDisplay()
    }
    
    
    override func draw(_ rect: CGRect) {
        
    
        if(flagLandscape) {
            delta = self.graphView!.bounds.size.width / CGFloat(self.graphView!.heightSeconds  / Double(graphView!.scale))

            let yC = self.graphView!.bounds.size.height/2 + (self.graphView!.bounds.size.height/2 - self.graphView!.priceToX(price: self.price!))
            let xC = self.graphView!.frame.origin.x + graphView!.frame.size.width + delta! * CGFloat(timeNeededToGoToGraph! - (Date.timeIntervalSinceReferenceDate - self.originalTimeStamp!))
            
            let p = graphView!.convert(CGPoint(x: xC, y: yC), to: self.superview)

            self.frame = CGRect(x: p.x - (originalWidth!/2) * graphView!.scale, y: p.y - (originalHeight!/2) * graphView!.scale, width: originalWidth! * graphView!.scale, height: originalHeight! * graphView!.scale)
        }
        else {
            delta = self.graphView!.bounds.size.height / CGFloat(self.graphView!.heightSeconds / Double(graphView!.scale) )

            let yC = graphView!.frame.size.height + delta! * CGFloat(timeNeededToGoToGraph! - (Date.timeIntervalSinceReferenceDate - self.originalTimeStamp!))
            let xC = self.graphView!.priceToX(price: self.price!)
            
            let p = graphView!.convert(CGPoint(x: xC, y: yC), to: self.superview)

            self.frame = CGRect(x: p.x - (originalWidth!/2) * graphView!.scale, y: p.y - (originalHeight!/2) * graphView!.scale, width: originalWidth! * graphView!.scale, height: originalHeight! * graphView!.scale)

        }
        var pointFire = CGPoint(x: self.graphView!.bounds.size.width/2 + scrollOffset, y: self.graphView!.bounds.size.height-10)
        if(flagLandscape) {
            pointFire = CGPoint(x: self.graphView!.bounds.size.width - 10, y: self.graphView!.bounds.size.height/2 + scrollOffset)
        }
        let pointInSelf = self.graphView!.convert(pointFire, to: self)
        
        if(self.bounds.contains(pointInSelf)) {
            self.timer?.invalidate()
            
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.cornerRadius = 4
                self.frame = CGRect(x: self.frame.origin.x + pointInSelf.x - 4, y: self.frame.origin.y + pointInSelf.y - 4, width: 8, height: 8)
            }, completion: { fin in
                self.fly()
            })
        }
        
//        if(((pointInSelf.y > self.bounds.size.height && flagLandscape == false) || (pointInSelf.x > self.bounds.size.width && flagLandscape == true)) && stopped == false) {  //remove immediately
        if(((self.frame.origin.y < (graphView!.frame.origin.y + 20) && flagLandscape == false) || (self.frame.origin.x < 0 && flagLandscape == true)) && stopped == false) {
            stopped = true
            UIView.animate(withDuration: 2, animations: {
                self.alpha = 0
            }, completion: {res in
                self.timer?.invalidate()
                self.removeFromSuperview()
            })
        }

    }
    
    func fly() {
        
        
        let point1 = self.superview!.convert(self.center, to: UIApplication.shared.keyWindow)
//        let point2 = graphView!.superview!.convert(graphView!.frame.origin, to: UIApplication.shared.keyWindow)
        
        let point2 = graphView!.convert(CGPoint(x: graphView!.bounds.size.width/2, y: -10), to: UIApplication.shared.keyWindow)

        
        
//        let fl = BOFlyingCoin(frame: graphView!.bounds)
        let fl = BOFlyingCoin(frame: graphView!.superview!.bounds)
        graphView?.superview!.addSubview(fl)

        

        let flying = fl.layer as! BOFlyingCoinLayer
        
        flying.value = self.value
        flying.presenter = self.presenter
        flying.backgroundColor = nil
        flying.isOpaque = false
        fl.isUserInteractionEnabled = false
//        flying.startPoint = UIApplication.shared.keyWindow?.convert(point1, to: self.graphView!)
//        flying.endPoint = UIApplication.shared.keyWindow?.convert(point2, to: self.graphView!)
        
        flying.startPoint = point1
        flying.endPoint = point2

        flying.calcValues()
        

        fl.startAnimation()
        
        self.removeFromSuperview()
        return;
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
    
}


