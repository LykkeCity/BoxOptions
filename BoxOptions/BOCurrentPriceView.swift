//
//  BOCurrentPriceView.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 07/05/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation


class BOCurrentPriceView: UIView {
    
    private var _price: String = ""
    
    var price: String? {
        get {
            return _price
        }
        
        set {
            _price = newValue!
            label?.text = _price
            label?.sizeToFit()
            self.frame = CGRect(x: 0, y: 0, width: label!.bounds.size.width + 10, height: label!.bounds.size.height + 10)
            label?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
            self.centerPoint = _centerPoint
        }
    }
    
    private var _centerPoint: CGPoint = .zero
    
    
    var centerPoint: CGPoint? {
        get {
            return _centerPoint
        }
        
        set {
            _centerPoint = newValue!
            if(flagLandscape) {
                self.center = CGPoint(x: _centerPoint.x + self.bounds.size.height/2, y: _centerPoint.y)
            }
            else {
                self.center = CGPoint(x: _centerPoint.x, y: _centerPoint.y + self.bounds.size.height/2)
            }
        }
    }
    
    private var label: UILabel?
    
    
//    override func init(frame: CGRect) {
//        
//    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        
        self.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.88)
        
        label = UILabel()
        label?.font = UIFont.init(name: "ProximaNova-Regular", size: 14)
        label?.textColor = UIColor.init(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
        self.addSubview(label!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    func orientationChanged() {
        self.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if(UIDevice.current.orientation.isPortrait) {
            self.transform = CGAffineTransform.identity
        }
        else {
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(-M_PI_2))
 //           self.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1)
        }
        
        //        if(flagLandscape) {
        //            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(-M_PI_2))
        //
        //        }
        //        else {
        //
        //            self.transform = CGAffineTransform.identity
        //        }
        //            currentOrientationIsLandscape = flagLandscape
        //            self.setNeedsLayout()
        //        }

    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(UIColor(red: 13.0/255, green: 167.0/255 ,blue: 252.0/255, alpha: 1).cgColor)
    context!.fillEllipse(in: CGRect(x: self.bounds.size.width/2 - 3, y: -4, width: 6, height: 6))

    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
