//
//  BOGamePresenter.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 10/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation
import UIKit


class BOGamePresenter: UIViewController {
    
    
    @IBOutlet weak var graphView: BOGraphView?
    @IBOutlet weak var keyboardView: BOKeyboardView?
    
    var asset: BOAsset?
    
    var timer:Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardView!.presenter = self
        
        graphView?.changes = asset?.changes as? [BORate]
        
        graphView?.widthPrice = (graphView!.changes!.last!.ask - graphView!.changes!.last!.bid) * 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(pricesChanged), name: NSNotification.Name("PricesChanged" + asset!.identity), object: nil)

//        timer = Timer.init(timeInterval: 0.03, repeats: true, block: { t in
//            self.graphView?.setNeedsDisplay()
//        })
        
        timer = Timer.init(timeInterval: 0.04, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
    }
    
    func timerFired() {
        self.graphView?.setNeedsDisplay()
    }
    
    func pricesChanged() {
        graphView?.changes = asset!.changes as! [BORate]
        graphView?.setNeedsDisplay()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(true, with: .none)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
}
