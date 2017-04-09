//
//  BOGamePresenter.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit


let minimumScale: CGFloat = 0.6
let maximumScale: CGFloat = 1.5

let BoxColumns = 15.0 //21.0
let BoxRows = 8.0 //12.0



var flagLandscape = false

enum COLOR_MODE {
    case light
    case dark
}

let mode: COLOR_MODE = .light

var scrollOffset: CGFloat = 0

class BOGamePresenter: UIViewController {
    
    private var _balance: Double?
    var balance:Double {
        get {
            if(_balance != nil) {
                return _balance!
            }
            
            return 0
            
        }
        
        set {
            let previous = _balance
            _balance = newValue
            
//            var str = NSMutableAttributedString(string: "Available " + ( NSString.init(format: "%.2f", _balance!) as String) )
//            str.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 17), range: NSMakeRange(0, str.length - 8))
            balanceLabel?.text = "Available " + ( NSString.init(format: "%.2f", _balance!) as String)
            if(previous != nil && _balance! > previous!) {
                UIView.animate(withDuration: 0.1, animations: {
                    self.balanceLabel?.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
                    self.balanceLabel?.textColor = UIColor(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
                }, completion: { finished in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.balanceLabel?.textColor = UIColor(red: 63.0/255, green: 77.0/255, blue: 96.0/255, alpha: 1)
                        self.balanceLabel?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                    })
                })
            }
            //balanceLabel?.text = (NSString.init(format: "%.2f", _balance!) as String) + " Balance"
        }
    }
    
    @IBOutlet weak var graphView: BOGraphView?
    @IBOutlet weak var keyboardView: BOKeyboardView?
    
    @IBOutlet weak var balanceLabel:UILabel?
    @IBOutlet weak var currentRateLabel: UILabel?
    @IBOutlet weak var utilsView: BOUtilsView?
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet weak var backButton: UIButton?
    @IBOutlet weak var titleContainerView: UIView?
    
    var showSettingsButton: UIButton?
    
    var titleLineView: UIView?
    var gradientView: UIImageView?
    
    
    var asset: BOAsset?
    
    var timer:Timer?
    
    var startScrollPoint:CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BODataManager.sendLogEvent(BOEventGameStarted, message: asset!.identity)
        
        if(mode == .light) {
            self.view.backgroundColor = .white
//            graphView?.backgroundColor = .white
            keyboardView?.backgroundColor = nil
        }
        
        self.view.clipsToBounds = true
        
        showSettingsButton = UIButton.init(type: .custom)
        showSettingsButton?.setBackgroundImage(#imageLiteral(resourceName: "GearWheel"), for: .normal)
        showSettingsButton?.addTarget(self, action: #selector(showSettingsButtonPressed), for: .touchUpInside)
        self.view.addSubview(showSettingsButton!)
        
        utilsView?.isHidden = true;
        
        titleLineView = UIView(frame: CGRect(x: 0, y: titleContainerView!.bounds.size.height - 0.5, width: titleContainerView!.bounds.size.width, height: 0.5))
        titleLineView!.backgroundColor = UIColor(red: 207.0/255, green: 210.0/255, blue: 215.0/255, alpha: 1)
        titleLineView!.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        titleContainerView?.addSubview(titleLineView!)
        
        balance = 50
        keyboardView!.presenter = self
        utilsView?.graphView = graphView
        utilsView?.presener = self
        
        graphView?.changes = asset?.changes as? [BORate]
        graphView?.accuracy = Int(asset!.accuracy)
        
//        graphView?.widthPrice = (graphView!.changes!.last!.ask - graphView!.changes!.last!.bid) * 4 * 4
        
//        NSArray *allowedAssets = @[@"EURUSD", @"EURAUD", @"EURCHF", @"EURGBP", @"EURJPY", @"USDCHF"];

        let ww = 0.0001 //0.0005
        let widthPrices = ["EURUSD":ww, "EURAUD":ww, "EURCHF":ww, "EURGBP":ww, "EURJPY": 0.03, "USDCHF":ww]
        
        graphView?.widthPrice = widthPrices[asset!.identity]
        
        gradientView = UIImageView(image: #imageLiteral(resourceName: "GradientImage"))
        self.view.insertSubview(gradientView!, belowSubview: graphView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pricesChanged), name: NSNotification.Name("PricesChanged" + asset!.identity), object: nil)
        
        currentRateLabel?.text = asset!.identity
        titleLabel?.attributedText =  NSAttributedString.init(string: asset!.identity, attributes: [NSFontAttributeName: UIFont.init(name: "ProximaNova-Semibold", size: 17)!, NSKernAttributeName: 1.5])
        
        titleLabel?.sizeToFit()
        
        timer = Timer.init(timeInterval: 0.02, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
        
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomDetected(gesture:)))
        self.view.addGestureRecognizer(gesture)
        let gesture1 = UIPanGestureRecognizer(target: self, action: #selector(dragDetected(gesture:)))
        self.view.addGestureRecognizer(gesture1)
        

    }
    
    func showSettingsButtonPressed() {
        if(utilsView!.isHidden) {
            utilsView?.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height + utilsView!.bounds.size.height/2)
            utilsView?.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.utilsView?.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - self.utilsView!.bounds.size.height/2)
                self.showSettingsButton?.center = CGPoint(x: self.view.bounds.size.width - 20 - self.showSettingsButton!.bounds.size.width/2, y: self.view.bounds.size.height - self.utilsView!.bounds.size.height - 20 - self.showSettingsButton!.bounds.size.height/2)
            
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                self.utilsView?.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height + self.utilsView!.bounds.size.height/2)
                self.showSettingsButton?.center = CGPoint(x: self.view.bounds.size.width - 20 - self.showSettingsButton!.bounds.size.width/2, y: self.view.bounds.size.height - 20 - self.showSettingsButton!.bounds.size.height/2)
                
            }, completion: { finished in
                self.utilsView?.isHidden = true
                
            })
  
        }
    }
    
    func zoomDetected(gesture: UIPinchGestureRecognizer) {
        
        graphView!.scale = graphView!.scale * gesture.scale
        if(graphView!.scale * CGFloat(keyboardScale) < minimumScale) {
            graphView!.scale = minimumScale / CGFloat(keyboardScale)
        }
        if(graphView!.scale * CGFloat(keyboardScale) > maximumScale) {
            graphView!.scale = maximumScale / CGFloat(keyboardScale)
        }
        gesture.scale = 1
        
        self.view.setNeedsLayout()
    }
    
    func dragDetected(gesture: UIPanGestureRecognizer) {
        let point=gesture.location(in: self.view)
        
        if(gesture.state == .began) {
            startScrollPoint = point
        }
        else {
            if(flagLandscape) {
                scrollOffset += point.y - startScrollPoint!.y
            }
            else {
                scrollOffset += point.x - startScrollPoint!.x
            }
            startScrollPoint = point
        }
        
        if(scrollOffset > keyboardView!.maxScrollOffset!) {
            scrollOffset = keyboardView!.maxScrollOffset!
        }
        if(scrollOffset < -keyboardView!.maxScrollOffset!) {
            scrollOffset = -keyboardView!.maxScrollOffset!
        }
        
        graphView?.setNeedsLayout()
        keyboardView?.setNeedsLayout()

        
    }
    
    
    
    func timerFired() {
        
        if(BODataManager.shared().flagConnected == false) {
            self.view.isUserInteractionEnabled = false
            return
        }
        
        if(self.view.isUserInteractionEnabled == false) {
            self.view.isUserInteractionEnabled = true
        }
        
        self.graphView?.setNeedsDisplay()
        

    }
    
    func pricesChanged() {
        graphView?.changes = asset!.changes.copy() as! [BORate]
        currentRateLabel?.text = asset!.identity + ": " + String((graphView!.changes!.last!.ask + graphView!.changes!.last!.bid)/2)
        graphView?.setNeedsDisplay()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        timer?.invalidate()
        keyboardView?.timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        return
        
        let distToKeyboard = 40.0 * graphView!.scale
        
        let graphSizeCoeff: CGFloat = 1
        
        
        if(self.view.bounds.size.width > self.view.bounds.size.height) {
            flagLandscape = true
            graphView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.height * graphSizeCoeff, height: self.view.bounds.size.height)
            gradientView?.image = #imageLiteral(resourceName: "GradientImageRotated")
            gradientView?.frame = CGRect(x: 0, y: graphView!.frame.origin.y, width: graphView!.bounds.size.width - 10, height: graphView!.frame.size.height)

            keyboardView?.frame = CGRect(x: graphView!.bounds.size.width + distToKeyboard, y: 0, width: self.view.bounds.size.width - (graphView!.bounds.size.width + distToKeyboard), height: self.view.bounds.size.height)

            titleContainerView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 52)
            titleLineView?.isHidden = false
            balanceLabel?.textAlignment = .right
            balanceLabel?.frame = CGRect(x: self.view.bounds.size.width - 20 - 200, y: 16, width: 200, height: 20)
            
            titleLabel?.center = CGPoint(x: 51 + titleLabel!.bounds.size.width/2, y: titleContainerView!.bounds.size.height/2)
            
            backButton?.frame = CGRect(x: 16, y: 12, width: 28, height: 28)
            
            
            
//            balanceLabel?.center.y = currentRateLabel!.center.y

//            currentRateLabel?.frame = CGRect(x: 10, y: self.view.bounds.size.height - 10 - 20, width: 200, height: 20)
            
//            utilsView!.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 30)
            
            
            utilsView?.frame = CGRect(x: 0, y: self.view.bounds.size.height - 56, width: self.view.bounds.size.width, height: 56)
            
            if(utilsView!.isHidden) {
                showSettingsButton?.frame = CGRect(x: self.view.bounds.size.width - 20 - 48, y: self.view.bounds.size.height - 20 - 48, width: 48, height: 48)
            }
            else {
                showSettingsButton?.frame = CGRect(x: self.view.bounds.size.width - 20 - 48, y: self.view.bounds.size.height - utilsView!.bounds.size.height - 20 - 48, width: 48, height: 48)
            }
        }
        else {
            flagLandscape = false
            graphView?.frame = CGRect(x: 0, y: 90, width: self.view.bounds.size.width, height: self.view.bounds.size.width * graphSizeCoeff - 90)
            
            gradientView?.frame = CGRect(x: 0, y: graphView!.frame.origin.y + 20, width: self.view.bounds.size.width, height: graphView!.frame.size.height - 20 - 10)
            gradientView?.image = #imageLiteral(resourceName: "GradientImage")
            keyboardView?.frame = CGRect(x: 0, y: graphView!.frame.origin.y + graphView!.bounds.size.height + distToKeyboard, width: self.view.bounds.size.width , height: self.view.bounds.size.height - (graphView!.frame.origin.y + graphView!.bounds.size.height + distToKeyboard))

            titleContainerView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 80)
            titleLineView?.isHidden = true
            balanceLabel?.textAlignment = .center
            balanceLabel?.frame = CGRect(x: self.view.bounds.size.width/2 - 100, y: 60, width: 200, height: 20)
            
            titleLabel?.center = CGPoint(x: self.view.bounds.size.width/2, y: 42)
            
            backButton?.frame = CGRect(x: 16, y: 28, width: 28, height: 28)

            
            utilsView?.frame = CGRect(x: 0, y: self.view.bounds.size.height - 56, width: self.view.bounds.size.width, height: 56)

            if(utilsView!.isHidden) {
                showSettingsButton?.frame = CGRect(x: self.view.bounds.size.width - 20 - 48, y: self.view.bounds.size.height - 20 - 48, width: 48, height: 48)
            }
            else {
                showSettingsButton?.frame = CGRect(x: self.view.bounds.size.width - 20 - 48, y: self.view.bounds.size.height - utilsView!.bounds.size.height - 20 - 48, width: 48, height: 48)
            }

            
//            balanceLabel?.frame = CGRect(x: self.view.bounds.size.width - 200 - 10, y: 10, width: 200, height: 20)
//            balanceLabel?.center.y = currentRateLabel!.center.y
//            balanceLabel?.textAlignment = .right
//            currentRateLabel?.frame = CGRect(x: self.view.bounds.size.width - 200 - 10, y: 10, width: 200, height: 20)
//            utilsView!.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 56/2)

        }
        
        utilsView?.setNeedsLayout()
//        utilsView?.layoutIfNeeded()

        
        keyboardView?.setNeedsLayout()
        
    }
    
    @IBAction func closePressed() {
        BODataManager.sendLogEvent(BOEventGameClosed, message: asset!.identity)

        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return !(UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation))
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .allButUpsideDown
        }
    }
    
    override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    deinit {
        
    }
    
}
