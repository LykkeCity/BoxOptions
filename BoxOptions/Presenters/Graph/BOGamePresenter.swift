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

var flagLandscape = false

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
            _balance = newValue
            balanceLabel?.text = "Balance: " + (NSString.init(format: "%.2f", _balance!) as String)
        }
    }
    
    @IBOutlet weak var graphView: BOGraphView?
    @IBOutlet weak var keyboardView: BOKeyboardView?
    
    @IBOutlet weak var balanceLabel:UILabel?
    @IBOutlet weak var currentRateLabel: UILabel?
    @IBOutlet weak var utilsView: BOUtilsView?
    
    var asset: BOAsset?
    
    var timer:Timer?
    
    var startScrollPoint:CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        balance = 50
        keyboardView!.presenter = self
        utilsView?.graphView = graphView
        utilsView?.presener = self
        
        graphView?.changes = asset?.changes as? [BORate]
        
        graphView?.widthPrice = (graphView!.changes!.last!.ask - graphView!.changes!.last!.bid) * 4
        
        NotificationCenter.default.addObserver(self, selector: #selector(pricesChanged), name: NSNotification.Name("PricesChanged" + asset!.identity), object: nil)

//        timer = Timer.init(timeInterval: 0.03, repeats: true, block: { t in
//            self.graphView?.setNeedsDisplay()
//        })
        
        currentRateLabel?.text = asset!.identity
        
        timer = Timer.init(timeInterval: 0.04, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
        
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomDetected(gesture:)))
        self.view.addGestureRecognizer(gesture)
        let gesture1 = UIPanGestureRecognizer(target: self, action: #selector(dragDetected(gesture:)))
        self.view.addGestureRecognizer(gesture1)

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
        self.graphView?.setNeedsDisplay()
    }
    
    func pricesChanged() {
        graphView?.changes = asset!.changes as! [BORate]
        currentRateLabel?.text = asset!.identity + ": " + String((graphView!.changes!.last!.ask + graphView!.changes!.last!.bid)/2)
        graphView?.setNeedsDisplay()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let distToKeyboard = 40.0 * graphView!.scale
        
        
        if(self.view.bounds.size.width > self.view.bounds.size.height) {
            flagLandscape = true
            graphView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.height * 0.75, height: self.view.bounds.size.height)
            keyboardView?.frame = CGRect(x: graphView!.bounds.size.width + distToKeyboard, y: 0, width: self.view.bounds.size.width - (graphView!.bounds.size.width + distToKeyboard), height: self.view.bounds.size.height)

            balanceLabel?.frame = CGRect(x: 10, y: 10, width: 200, height: 20)
            currentRateLabel?.textAlignment = .left
            currentRateLabel?.frame = CGRect(x: 10, y: self.view.bounds.size.height - 10 - 20, width: 200, height: 20)
            
            utilsView!.center = CGPoint(x: self.view.bounds.size.width - 20, y: self.view.bounds.size.height/2)
        }
        else {
            flagLandscape = false
            graphView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.width * 0.75)
            keyboardView?.frame = CGRect(x: 0, y: graphView!.bounds.size.height + distToKeyboard, width: self.view.bounds.size.width , height: self.view.bounds.size.height - (graphView!.bounds.size.height + distToKeyboard))
            balanceLabel?.frame = CGRect(x: 10, y: 10, width: 200, height: 20)
            
            currentRateLabel?.textAlignment = .right
            currentRateLabel?.frame = CGRect(x: self.view.bounds.size.width - 200 - 10, y: 10, width: 200, height: 20)
            utilsView!.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height - 20)

        }
        
        utilsView?.setNeedsLayout()
//        utilsView?.layoutIfNeeded()

        
        keyboardView?.setNeedsLayout()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
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
    
}
