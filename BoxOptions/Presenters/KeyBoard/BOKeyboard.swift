//
//  BOKeyboard.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit

var numberOfColumnsOnScreen = 5

class BOKeyboardView: UIView {
    
    var keysArray:Array<BOKeyView>?
    
    var maxScrollOffset:CGFloat?
    
    var etalon: CGFloat?
    
    var timer: Timer?
    
    var flagParamsSent: Bool?
    
    weak var presenter: BOGamePresenter?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        flagParamsSent = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.sendParams()
        }
        
        timer = Timer.init(timeInterval: 5, target: self, selector: #selector(refreshCoeffs), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
        
    }
    
    func refreshCoeffs() {
        
        if(flagParamsSent == false || presenter == nil) {
            return
        }
        BODataManager.shared().requestCoeffs(forPair: self.presenter!.asset!.identity, withCompletion: { result in
            let arr = result as! [Double]
            
            var horNumber = BoxColumns
            var verNumber = BoxRows
            
            if(flagLandscape) {
                horNumber = BoxRows
                verNumber = BoxColumns
                
            }
            
            for j in 0..<Int(verNumber) {
                for i in 0..<Int(horNumber) {
                    let keyView = self.keysArray![Int(j) * Int(horNumber) + Int(i)]
                    keyView.value = arr[Int(j) * Int(horNumber) + Int(i)]
                }
            }
            self.setNeedsLayout()
        })

    }
    
    func clearCoefficents() {
        flagParamsSent = false
        for v in keysArray! {
            v.value = 0
        }

    }
    
    func sendParams() {
        
        flagParamsSent = false
        
        clearCoefficents()
        
        var distToGraph: CGFloat?
        var timeNeededToGoToGraph: Double?
        var delta: CGFloat?
        
        let graphView = presenter?.graphView
        if(flagLandscape) {
            
            let p = graphView!.convert(CGPoint(x: graphView!.bounds.size.width, y: 0), to: self)
            distToGraph = -p.x
        }
        else {
            let p = graphView!.convert(CGPoint(x: 0, y: graphView!.bounds.size.height), to: self)
            distToGraph = -p.y
        }
        
        if(flagLandscape) {
            delta = graphView!.bounds.size.width / CGFloat(graphView!.heightSeconds  / Double(graphView!.scale))
            timeNeededToGoToGraph = Double(distToGraph! / delta!)
        }
        else {
            delta = graphView!.bounds.size.height / CGFloat(graphView!.heightSeconds  / Double(graphView!.scale))
            timeNeededToGoToGraph = Double(distToGraph! / delta!)
        }

        let boxTimeLength = Double(etalon! * self.presenter!.graphView!.scale)/Double(delta!)
        

        BODataManager.shared().sendParameters(forAsset: presenter!.asset!.identity, timeToGraph: timeNeededToGoToGraph!, boxPriceWidth: (presenter!.graphView!.widthPrice!/Double(numberOfColumnsOnScreen)) * Double(keyboardScale), boxTimeLength: boxTimeLength, columns: Int32(BoxColumns), rows: Int32(BoxRows), withCompletion: { res in
            self.flagParamsSent = true
            self.refreshCoeffs()
        })
        
       // @{@"pair":@"EURUSD", @"timeToFirstOption":@(4000), @"optionLen":@(4000), @"priceSize":@(0.005), @"nPriceIndex":@(10), @"nTimeIndex":@(5)
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.keysArray == nil) {
            self.keysArray = Array()
            
        }

        etalon = (self.bounds.size.height/CGFloat(numberOfColumnsOnScreen)) * CGFloat(keyboardScale)
        
        
        if(flagLandscape == false) {
            etalon = (self.bounds.size.width/CGFloat(numberOfColumnsOnScreen))  * CGFloat(keyboardScale)
        }
        
        var horNumber = BoxColumns
        var verNumber = BoxRows
        
        maxScrollOffset = etalon! * CGFloat(horNumber / 2) * presenter!.graphView!.scale

        
        if(flagLandscape) {
            horNumber = BoxRows
            verNumber = BoxColumns
            
        }
        
        
        
        var value = 1.0

        let width = etalon! * self.presenter!.graphView!.scale
        let height = width

        var maxLabelText: String?
        var maxLabelWidth: CGFloat = 0.0
        
        let attributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 18)]
            if(flagLandscape) {
                
                
                
                
                for i in 0..<Int(horNumber) {
                    for j in 0..<Int(verNumber) {
                        
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        
                        let center = CGPoint(x: (CGFloat(i) + 0.5) * width, y: self.bounds.size.height/2 - (CGFloat(verNumber/2) - CGFloat(j) - 0.5) * height + scrollOffset)
                        
                        value = Double(i)*0.7/keyboardScale + 1.1 + fabs(verNumber/2 - Double(0.5) - Double(j))*1.1/keyboardScale
                        
                        
                        var keyView: BOKeyView?
                        
                        if(self.keysArray!.count < Int(horNumber * verNumber)) {
                            keyView = BOKeyView.init(frame: frame, value: value)
                            keyView!.presenter = self.presenter
                            keyView?.value = 0
                            self.keysArray?.append(keyView!)
                        }
                        else {
                            keyView = self.keysArray![Int(i) * Int(verNumber) + Int(j)]
                        }
                        
                            keyView!.frame = frame
                            keyView!.center = center
                            keyView!.value = keyView?.value

                            if(keyView!.superview == nil) {
                                self.addSubview(keyView!)
                            }
                        
                        keyView?.flagIsRight = (j == Int(verNumber)-1)

                        let string = keyView!.label!.text
                        let size = string!.size(attributes: attributes)
                        if(size.width > maxLabelWidth) {
                            maxLabelWidth = size.width
                            maxLabelText = string!
                        }
                        
                    }
                    
                }
            }
                
            else {
                
                
                for j in 0..<Int(verNumber) {
                    for i in 0..<Int(horNumber) {
                    
                        let frame = CGRect(x: 0, y: 0, width: width, height: height)
                        
                        let center = CGPoint(x: self.bounds.size.width/2 - (CGFloat(horNumber/2) - CGFloat(i) - 0.5) * width + scrollOffset, y: (CGFloat(j)+0.5) * height)
                        
                        value = Double(j)*0.7/keyboardScale + 1.1 + fabs(horNumber/2 - Double(0.5) - Double(i))*1.1/keyboardScale
                        
                        
                        var keyView: BOKeyView?
                        
                        if(self.keysArray!.count < Int(horNumber * verNumber)) {
                            keyView = BOKeyView.init(frame: frame, value: value)
                            keyView!.presenter = self.presenter
                            keyView?.value = 0
                            self.keysArray?.append(keyView!)
                        }
                        else {
                            keyView = self.keysArray![Int(j) * Int(horNumber) + Int(i)]
                        }
                        
                        keyView!.frame = frame
                        keyView!.center = center
                        keyView!.value = keyView?.value
                        if(keyView!.superview == nil) {
                            self.addSubview(keyView!)
                        }
                        
                        
                        keyView?.flagIsRight = (i == Int(horNumber)-1)
                        
                        let string = keyView!.label!.text
                        let size = string!.size(attributes: attributes)
                        if(size.width > maxLabelWidth) {
                            maxLabelWidth = size.width
                            maxLabelText = string!
                        }

                    }
                }
                
            }
        
        var fontSize: CGFloat = 18
        while(maxLabelText!.size(attributes: [NSFontAttributeName : UIFont(name: "ProximaNova-Regular", size: fontSize)!]).width > width - 8) {
            fontSize = fontSize - 1
        }
        let maxFont = UIFont(name: "ProximaNova-Regular", size: fontSize)
        for j in 0..<Int(verNumber) {
            for i in 0..<Int(horNumber) {
                let keyView = self.keysArray![Int(j) * Int(horNumber) + Int(i)]
                keyView.label?.font = maxFont
            }
        }
    
        
        for v in presenter!.activeOptions! {
            fontSize = 18
            while(v.label.text!.size(attributes: [NSFontAttributeName : UIFont(name: "ProximaNova-Regular", size: fontSize)!]).width > v.bounds.size.width - 8) {
                fontSize = fontSize - 1
            }
            v.label.font = UIFont(name: "ProximaNova-Regular", size: fontSize)
        }
        
        
//            sendParams()
        }
        

    
    
    
    
    
}

class BOKeyView: UIView {
    var flagIsRight: Bool?
    
    weak var presenter: BOGamePresenter?
    
    private var _value: Double?
    
    var value:Double? {
        get {
            if(_value == nil) {
                _value = 0
            }
            return _value
        }
        set {
            _value = newValue
            if(label != nil) {
               let ee = label?.frame
                let eee = box?.frame
                
                if(_value == 0) {
                    label?.text = "..."
                    self.isUserInteractionEnabled = false
                }
                else {
                    self.isUserInteractionEnabled = true
                    label?.text = NSString.init(format: "%.2f", _value! * betAmount) as String
                }
                
                self.setNeedsLayout()
            }
        }
    }
    
    var label: UILabel?
    var box:UIView?
    
    init(frame: CGRect, value: Double) {
        super.init(frame: frame)
        self.clipsToBounds = true
        box = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width+10, height: frame.size.height+10))
        box?.isUserInteractionEnabled = false
        self.backgroundColor = nil
        
        label = UILabel()
//        label?.font = UIFont(name: "ProximaNova-Regular", size: 14)
        
        if(mode == .light) {
            box!.layer.borderColor = UIColor(red: 216.0/255, green: 216.0/255, blue: 216.0/255, alpha: 1).cgColor
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
        
        label?.clipsToBounds = true

        label?.textAlignment = .center
        label?.frame = box!.frame
        
        self.addSubview(label!)
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(userTapped))
        self.addGestureRecognizer(gesture)
        
        self.value = value
        
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        label?.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        let frame = self.frame
        
        let m: CGFloat = flagIsRight! ? 0 : 0.5
        if(flagLandscape == false) {
            box?.frame = CGRect(x: 0, y: 0, width: frame.size.width + m, height: frame.size.height + 0.5)
        }
        else {
            box?.frame = CGRect(x: 0, y: 0, width: frame.size.width + 0.5, height: frame.size.height + m)

        }
        
        label?.frame = box!.bounds


    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func userTapped() {
        if(presenter!.balance < betAmount) {
            return
        }
        
        
        BODataManager.shared().sendLogEvent(BOEventBetPlaced, message: "Coeff: " + String(_value!) + ", Bet: " + String(betAmount))

        presenter?.balance -= betAmount

        let optionView = BOOptionView.init(frame: self.convert(self.bounds, to: self.superview!.superview!), inView:self.superview!.superview!, value: value! * betAmount, presenter: presenter!)
        optionView.optionBetAmount = betAmount
        presenter?.activeOptions!.append(optionView)
        print("TAPPED")
    }
}

class BOOptionView: UIView {
    
    var value:Double?
    var optionBetAmount: Double?
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
    
    var priceLength: Double?
    var timeLength: Double?
    
    var delta:CGFloat?

    var timer: Timer?
    
    var stopped = false
    
    var flagWon = false
    
    var flagLost = false
    
    let label = UILabel()
    
    var betBox: BOBetBox?

    
    init(frame: CGRect, inView: UIView, value: Double, presenter: BOGamePresenter) {
        super.init(frame: frame)
        betBox = BOBetBox()
        self.presenter = presenter
        graphView = presenter.graphView

        var index = 0
        if(inView.subviews.count > 0) {
            if(inView.subviews[0] is BOKeyboardView) {
                index = 1
            }
        }
//        inView.insertSubview(self, at: index)
        
        inView.insertSubview(self, aboveSubview: graphView!)
        
        self.clipsToBounds = true
        self.value = value
        
        originalWidth = frame.size.width / presenter.graphView!.scale
        originalHeight = frame.size.height / presenter.graphView!.scale
        
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
            timeLength = Double(self.bounds.size.width / delta!)
            priceLength =  graphView!.xToPrice(x: frame.origin.y) - graphView!.xToPrice(x: frame.origin.y + frame.size.height)
            
            betBox?.startPrice = graphView!.xToPrice(x: frame.origin.y)
            betBox?.endPrice = graphView!.xToPrice(x: frame.origin.y + frame.size.height)
            

        }
        else {
            price = graphView!.xToPrice(x: frame.origin.x + frame.size.width/2)

            delta = self.graphView!.bounds.size.height / CGFloat(self.graphView!.heightSeconds  / Double(graphView!.scale))
            
            timeNeededToGoToGraph = Double(distToGraph! / delta!)

            timeLength = Double(self.bounds.size.height / delta!)
            priceLength =  graphView!.xToPrice(x: frame.origin.x + frame.size.width) - graphView!.xToPrice(x: frame.origin.x)

            betBox?.startPrice = graphView!.xToPrice(x: frame.origin.x)
            betBox?.endPrice = graphView!.xToPrice(x: frame.origin.x + frame.size.width)

        }
        
        betBox?.timeToGraph = timeNeededToGoToGraph! + Double(10.0 / delta!) - timeLength! / 2
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 12.295) {
//            self.backgroundColor = UIColor.yellow
//        }

        
        betBox?.timeLength = timeLength!
        betBox?.betAmount = betAmount
        betBox?.coeff = value
        
        betBox?.identity = UUID().uuidString
        betBox?.assetPair = presenter.asset
        betBox?.timeStamp = Date.timeIntervalSinceReferenceDate
        
        BODataManager.shared().sendBetEvent(for: betBox!)

        
        NotificationCenter.default.addObserver(self, selector: #selector(checkPrice(notification:)), name: Notification.Name("PricesChanged" + presenter.asset!.identity), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(boxWinEventFromServer), name: Notification.Name("BoxWinWithId" + betBox!.identity), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(boxLoseEventFromServer), name: Notification.Name("BoxLoseWithId" + betBox!.identity), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(betPlacedEventFromServer(notification:)), name: Notification.Name("BoxPlacedWithId" + betBox!.identity), object: nil)

    }
    
    func betPlacedEventFromServer(notification: Notification) {
        let object = notification.object as! NSNumber
        originalTimeStamp = object.doubleValue
        betBox?.timeStamp = originalTimeStamp!
        timer = Timer.init(timeInterval: 0.04, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)

    }
    
    func boxWinEventFromServer() {
        
        let time = Date.timeIntervalSinceReferenceDate
        let passed = time - betBox!.timeStamp

//        self.backgroundColor = UIColor.green
        boxWin()
        
    }
    
    func boxLoseEventFromServer() {
        
        let time = Date.timeIntervalSinceReferenceDate
        let passed = time - betBox!.timeStamp
//        self.backgroundColor = UIColor.red
        NotificationCenter.default.removeObserver(self)
    }
    
    func timerFired () {
        self.setNeedsDisplay()
    }
    
    func checkPrice(notification: Notification) {
        
        
        let value = notification.object as! NSValue
        let point  = value.cgPointValue
        
//        let timeNow = Date.timeIntervalSinceReferenceDate
//        if(timeNow >= originalTimeStamp! + timeNeededToGoToGraph! - timeLength!/2 && timeNow <= originalTimeStamp! + timeNeededToGoToGraph! + timeLength!/2) {
//            if((Double(point.x) > price! && Double(point.y) < price!) || (Double(point.x) < price! && Double(point.y) > price!)) {
//                boxWin()
//            }
//        }
        
    }
    
    func boxWin() {
        if(flagWon == true) {
            return
        }
        flagWon = true
        self.timer?.invalidate()
        if let index = presenter?.activeOptions!.index(of:self) {
            presenter?.activeOptions!.remove(at: index)
        }

        
        BODataManager.shared().sendLogEvent(BOEventBetWon, message: "Value: " + String(value!))

        NotificationCenter.default.removeObserver(self)
        
//        return  //TEMPORARY FOR TESTING
        
        UIView.animate(withDuration: 0.1, animations: {
            self.layer.cornerRadius = 4

            self.frame = CGRect(x: self.center.x - 4, y: self.center.y - 4, width: 8, height: 8)

        }, completion: { fin in
            self.fly()
        })

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
        
//        if(self.bounds.contains(pointInSelf)) {
//            boxWin()
//        }
        
//        if(((pointInSelf.y > self.bounds.size.height && flagLandscape == false) || (pointInSelf.x > self.bounds.size.width && flagLandscape == true)) && stopped == false) {  //remove immediately
        
        if((self.frame.origin.y + self.bounds.size.height < graphView!.frame.origin.y + graphView!.bounds.size.height - 10) && flagLandscape == false ||
            (self.frame.origin.x + self.bounds.size.width < graphView!.frame.origin.x + graphView!.bounds.size.width - 10) && flagLandscape == true) {
            flagLost = true
        }
        
        if(((self.frame.origin.y < (graphView!.frame.origin.y + 20) && flagLandscape == false) || (self.frame.origin.x < 0 && flagLandscape == true)) && stopped == false) {
            stopped = true
            BODataManager.shared().sendLogEvent(BOEventBetLost, message: "Value: " + String(value!))

//            NotificationCenter.default.removeObserver(self)
//
//            UIView.animate(withDuration: 2, animations: {
//                self.alpha = 0
//            }, completion: {res in
//                self.timer?.invalidate()
//                self.removeFromSuperview()
//            })
        }
        
        if(stopped) {
            if(flagLandscape == false) {
                // Create a mask layer and the frame to determine what will be visible in the view.
                let maskLayer = CAShapeLayer()
                let dY = (graphView!.frame.origin.y + 20) - self.frame.origin.y
                let path = CGPath(rect: CGRect(x: 0, y: dY, width: self.bounds.size.width, height: self.bounds.size.height - dY), transform: nil)
                maskLayer.path = path
                
                self.layer.mask = maskLayer
                
                if(dY > self.bounds.size.height) {
                    timer?.invalidate()
                    self.removeFromSuperview()
                }
              }
            else {
                if(self.frame.origin.x < -self.bounds.size.width) {
                    timer?.invalidate()
                    self.removeFromSuperview()
                }
            }
            if let index = presenter?.activeOptions!.index(of:self) {
                presenter?.activeOptions!.remove(at: index)
            }
        }

    }
    
    func fly() {
        if(self.superview == nil) {
            NotificationCenter.default.removeObserver(self)
            return
        }
        
        let point1 = self.superview!.convert(self.center, to: UIApplication.shared.keyWindow)
//        let point2 = graphView!.superview!.convert(graphView!.frame.origin, to: UIApplication.shared.keyWindow)
        
        var point2: CGPoint?
        
        if(flagLandscape == false) {
//            point2 = graphView!.convert(CGPoint(x: graphView!.bounds.size.width/2, y: -10), to: UIApplication.shared.keyWindow)
            point2 = CGPoint(x: UIApplication.shared.keyWindow!.bounds.size.width - 80, y: 50)

        }
        else {
            point2 = CGPoint(x: UIApplication.shared.keyWindow!.bounds.size.width - 80, y: 25)
        }

        
        
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


