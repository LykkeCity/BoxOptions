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
    
    weak var presenter: BOGamePresenter?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(keysArray == nil) {
        keysArray = Array()
        let width = self.bounds.size.width/5
        
        var value = 1.0
        for i in 0..<5 {
            for j in 0..<5 {

                let frame = CGRect(x: CGFloat(i) * width, y: CGFloat(j) * width, width: width, height: width)
                let keyView = BOKeyView.init(frame: frame, value: value)
                self.addSubview(keyView)
                keyView.presenter = presenter
                value += 1
            }
        }
        }
        
        
    }
    
    
}

class BOKeyView: UIView {
    
    weak var presenter: BOGamePresenter?
    var value:Double?
    
    var label: UILabel?
    var box:UIView?
    
    init(frame: CGRect, value: Double) {
        super.init(frame: frame)
        self.value = value
        
        box = UIView(frame: CGRect(x: 3, y: 3, width: frame.size.width-6, height: frame.size.height-6))
        
        self.backgroundColor = nil
        box!.layer.borderColor = UIColor(red: 143.0/255, green: 125.0/255, blue: 25.0/255, alpha: 1).cgColor
        box!.layer.borderWidth = 0.5
        box!.backgroundColor = UIColor(red: 11.0/255, green: 3.0/255, blue: 55.0/255, alpha: 1)
        
        self.addSubview(box!)
        
        label = UILabel()
        label?.font = UIFont.systemFont(ofSize: 14)
        label?.textColor = UIColor(red: 1, green: 246.0/255, blue: 0, alpha: 1)
        label?.text = String(value)
        label?.sizeToFit()
        self.addSubview(label!)
        label?.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        self.addGestureRecognizer(gesture)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func userTapped() {
        let optionView = BOOptionView.init(frame: self.frame, value: value!, presenter: presenter!)
        self.superview!.insertSubview(optionView, at: 0)
    }
}

class BOOptionView: UIView {
    
    var value:Double?
    weak var graphView: BOGraphView?
    
    var originalY:CGFloat?
    var originalTimeStamp: Double?
    
    var price: Double?
    
    var delta:CGFloat?

    var timer: Timer?
    
    var stopped = false
    
    
    init(frame: CGRect, value: Double, presenter: BOGamePresenter) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = UIColor.yellow
        self.value = value
        
        self.layer.borderColor = UIColor.brown.cgColor
        self.layer.borderWidth = 2
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)

        label.backgroundColor = nil
        label.textColor = UIColor.black
        label.isOpaque = false
        label.text = String(value)
        label.sizeToFit()
        self.addSubview(label)
        label.center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        
        graphView = presenter.graphView
        originalY = frame.origin.y + frame.size.height/2
        originalTimeStamp = Date.timeIntervalSinceReferenceDate
        
        price = graphView!.xToPrice(x: frame.origin.x + frame.size.width/2)
        
        delta = self.graphView!.bounds.size.height / CGFloat(self.graphView!.heightSeconds)

        timer = Timer.init(timeInterval: 0.04, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func timerFired () {

        self.center.y = self.originalY! - delta! * CGFloat(Date.timeIntervalSinceReferenceDate - self.originalTimeStamp!)
        self.center.x = self.graphView!.priceToX(price: self.price!)
        
        let pointFire = CGPoint(x: self.graphView!.bounds.size.width/2, y: self.graphView!.bounds.size.height-10)
        let pointInSelf = self.graphView!.convert(pointFire, to: self)
        
        if(self.bounds.contains(pointInSelf)) {
            self.timer?.invalidate()
            
            UIView.animate(withDuration: 0.1, animations: {
                self.layer.cornerRadius = 15
                self.frame = CGRect(x: self.center.x - 15, y: self.center.y - 15, width: 30, height: 30)
            }, completion: { fin in
                self.fly()
            })
        }
        
        if(pointInSelf.y > self.bounds.size.height && stopped == false) {
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
        let point2 = graphView!.superview!.convert(graphView!.frame.origin, to: UIApplication.shared.keyWindow)
        
        
        
        let flying = BOFlyingCoin(frame: graphView!.bounds)
        flying.backgroundColor = nil
        flying.isOpaque = false
        
        graphView?.addSubview(flying)
        flying.startPoint = UIApplication.shared.keyWindow?.convert(point1, to: graphView!)
        flying.endPoint = UIApplication.shared.keyWindow?.convert(point2, to: graphView!)
        flying.calcValues()
        flying.startAnimation()
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
