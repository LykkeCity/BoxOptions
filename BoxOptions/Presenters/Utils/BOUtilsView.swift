//
//  BOUtilsView.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 18/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

var betAmount: Double = 1

var keyboardScale: Double = 1.0

class BOUtilsView: UIView {
    
    weak var graphView: BOGraphView?
    weak var presener: BOGamePresenter?
    
    var slider: UISlider?
    var currentOrientationIsLandscape = false
    
    var eyeButton: UIButton?
    
    
    
    var betView: BOUtilsBetView?
    
    var flagKeyboardHidden = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        self.frame = CGRect(x: 0, y: 0, width: min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height), height: 56)
        
        betView = BOUtilsBetView.init(frame: CGRect.zero)
        self.addSubview(betView!)
        
        eyeButton = UIButton.init(type: .custom)
        eyeButton?.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        eyeButton?.setBackgroundImage(#imageLiteral(resourceName: "EyeIconGray"), for: .normal)
        eyeButton?.addTarget(self, action: #selector(eyePressed), for: .touchUpInside)
        eyeButton?.center = CGPoint(x: self.bounds.size.width - (20 + 18), y: self.bounds.size.height / 2)
        eyeButton?.setBackgroundImage(#imageLiteral(resourceName: "EyeIconGray"), for: .selected)
        self.addSubview(eyeButton!)
        

        slider = UISlider()

        var sliderColor: UIColor
        if(mode == .light) {
            sliderColor = UIColor.init(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
            slider?.transform = CGAffineTransform.init(scaleX: 0.4, y: 0.4)
        }
        else {
         sliderColor = UIColor.init(red: 237.0/255, green: 234.0/255, blue: 87.0/255, alpha: 1)
        }
        slider?.setValue(0.5, animated: false)
        slider?.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider?.tintColor = sliderColor
        slider?.maximumTrackTintColor = UIColor(red: 207.0/255, green: 210.0/255, blue: 215.0/255, alpha: 1)
        slider?.thumbTintColor = sliderColor

        self.addSubview(slider!)
//        slider?.layer.shadowColor = yellow.cgColor
//        slider?.layer.shadowRadius = 5
//        slider?.layer.shadowOpacity = 0.7
        
        
//        self.transform = CGAffineTransform.init(rotationAngle: CGFloat(-M_PI_2))
//        self.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI_2), 0, 0, 1)

        
    }
    
    func eyePressed() {
        eyeButton!.isSelected = !eyeButton!.isSelected
        flagKeyboardHidden = !flagKeyboardHidden
        presener?.keyboardView?.alpha = flagKeyboardHidden ? 0.4 : 1.0
        if(flagKeyboardHidden) {
            presener!.keyboardView!.superview!.sendSubview(toBack: presener!.keyboardView!)
        }
        else {
            presener!.keyboardView!.superview!.bringSubview(toFront: presener!.keyboardView!)
            self.superview?.bringSubview(toFront: self)
        }
    }
    
    func closePressed() {
        presener?.dismiss(animated: true, completion: nil)
    }
    
    func sliderValueChanged() {
        keyboardScale = Double(slider!.value) + 0.5
        
        if(graphView!.scale * CGFloat(keyboardScale) < minimumScale) {
            graphView!.scale = minimumScale / CGFloat(keyboardScale)
        }
        if(graphView!.scale * CGFloat(keyboardScale) > maximumScale) {
            graphView!.scale = maximumScale / CGFloat(keyboardScale)
        }

        
        self.superview?.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        betView?.setNeedsLayout()
        betView!.layoutIfNeeded()
        
//        let point = self.center
//        betView?.center = CGPoint(x: self.bounds.size.width - (eyeButton!.bounds.size.width + 24 + betView!.bounds.size.width / 2 - 10), y: self.bounds.size.height / 2)

        betView?.center = CGPoint(x: betView!.bounds.size.width / 2 + 20, y: self.bounds.size.height / 2)

//        slider?.frame = CGRect(x: 12, y: 10, width: betView!.frame.origin.x - 20, height: 20)
        
        slider?.frame = CGRect(x: betView!.frame.origin.x + betView!.bounds.size.width + 20, y: 14, width: self.bounds.size.width - (betView!.frame.origin.x + betView!.bounds.size.width + 20 + eyeButton!.bounds.size.width + 40), height: 20)

        slider?.center.y = self.bounds.size.height / 2
        
//        self.center = point
        
//        betView?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        if(currentOrientationIsLandscape != flagLandscape ) {
        if(flagLandscape) {
            self.transform = CGAffineTransform.init(rotationAngle: CGFloat(-M_PI_2))
            
        }
        else {

            self.transform = CGAffineTransform.identity
        }
            currentOrientationIsLandscape = flagLandscape
            self.setNeedsLayout()
        }

    }
    
    
    
}


class BOUtilsBetView: UIView {
    
    
    var plusButton: UIButton?
    var minusButton: UIButton?
    var amountLabel: UILabel?
    
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        
        minusButton = UIButton.init(type: .custom)
        minusButton?.setBackgroundImage(#imageLiteral(resourceName: "MinusIconGray"), for: .normal)
        minusButton?.setBackgroundImage(#imageLiteral(resourceName: "MinusIconGray"), for: .highlighted)
        minusButton?.addTarget(self, action: #selector(minusPressed), for: .touchUpInside)
        minusButton?.frame = CGRect(x:0, y: 0, width: 36, height: 36)
        
        self.addSubview(minusButton!)
        
        amountLabel = UILabel.init(frame: CGRect(x: 36, y: 0, width: 50, height: 36))
        amountLabel?.text = String(Int(betAmount))
        amountLabel?.font = UIFont(name: "ProximaNova-Regular", size: 24)
        amountLabel?.textColor = UIColor(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
//        amountLabel?.backgroundColor = UIColor.init(red: 237.0/255, green: 234.0/255, blue: 87.0/255, alpha: 1)
        amountLabel!.textAlignment = .center
        
//        amountLabel!.layer.shadowColor = UIColor.init(red: 237.0/255, green: 234.0/255, blue: 87.0/255, alpha: 1).cgColor
//        amountLabel!.layer.shadowRadius = 5
//        amountLabel!.layer.shadowOpacity = 0.7

        self.addSubview(amountLabel!)


        
        plusButton = UIButton.init(type: .custom)
        plusButton?.setBackgroundImage(#imageLiteral(resourceName: "PlusIconGray"), for: .normal)
        plusButton?.setBackgroundImage(#imageLiteral(resourceName: "PlusIconGray"), for: .highlighted)
        plusButton?.addTarget(self, action: #selector(plusPressed), for: .touchUpInside)
        plusButton?.frame = CGRect(x:amountLabel!.frame.origin.x + amountLabel!.bounds.size.width, y: 0, width: 36, height: 36)
        self.addSubview(plusButton!)

        self.frame = CGRect(x:0, y:0, width: plusButton!.frame.origin.x + plusButton!.bounds.size.width, height: 36)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        let point = self.center
        
//        amountLabel?.sizeToFit()
//        
//            minusButton?.frame = CGRect(x:0, y: 0, width: 20, height: 20)
//            amountLabel?.frame = CGRect(x:30, y: 0, width: amountLabel!.bounds.size.width, height: 20)
//            plusButton?.frame = CGRect(x:amountLabel!.frame.origin.x + amountLabel!.bounds.size.width + 10, y: 0, width: 20, height: 20)
//            self.frame = CGRect(x:0, y:0, width: plusButton!.frame.origin.x + plusButton!.bounds.size.width, height: 20)
//            self.center = point
        
        
        
    }
    
    
    func plusPressed() {
        betAmount += 1
        amountLabel?.text = String(Int(betAmount))
        self.superview?.superview?.setNeedsLayout()

    }
    
    func minusPressed() {
        if(betAmount == 1) {
            return
        }
        betAmount -= 1
        amountLabel?.text = String(Int(betAmount))

        self.superview?.superview?.setNeedsLayout()

    }
    
    
    
    
    required init(coder aDecoder: NSCoder) { super.init(coder: aDecoder)! }
    
//    init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    
    
}

