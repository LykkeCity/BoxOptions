//
//  File.swift
//  BoxOptions
//
//  Created by Andrey Snetkov on 09/02/2017.
//  Copyright © 2017 Andrey Snetkov. All rights reserved.
//

import Foundation

import UIKit

class BOAssetsTablePresenter: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView:UITableView?
    
    @IBOutlet weak var balanceTitleLabel: UILabel?
    @IBOutlet weak var balanceLabel: UILabel?
    
    var animation: LOTAnimationView?
    
    var animationBackgroundView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balanceTitleLabel?.attributedText = NSAttributedString.init(string: "BALANCE", attributes: [NSKernAttributeName: 2.0, NSFontAttributeName: UIFont.init(name: "ProximaNova-Regular", size: 10)!, NSForegroundColorAttributeName: UIColor.init(red: 63.0/255, green: 77.0/255, blue: 96.0/255, alpha: 1)])
        
        
        tableView?.delegate = self
        tableView?.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(assetsListChanged), name: NSNotification.Name("AssetsListChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pricesChanged), name: NSNotification.Name("PricesChanged"), object: nil)
        
        tableView?.register(UINib(nibName: "LWMarginalAssetPairTableViewCell", bundle: nil), forCellReuseIdentifier: "MarginalAssetPairCellId")
        tableView?.separatorStyle = .none
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        let b = UserDefaults.standard.double(forKey: "UserBalance")
        var balance: Double?
        if(b != nil && b > 0) {
            balance = b
        }
        else {
            balance = 50
        }
        
        balanceLabel?.text = "USD " + String.init(format: "%.2f", balance!)

        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(animation == nil) {

            animationBackgroundView = UIView.init(frame: CGRect(x: 0, y: 0, width: 85, height: 85))
            animationBackgroundView?.backgroundColor = nil
            animationBackgroundView?.center = self.view.center
            animationBackgroundView?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]

            let backLayer = UIView.init(frame: animationBackgroundView!.bounds)
            backLayer.backgroundColor = UIColor.white
            backLayer.alpha = 0.9
            animationBackgroundView?.addSubview(backLayer)
            
            self.view.addSubview(animationBackgroundView!)
            
            
            animation = LOTAnimationView(name: "box_loader.json")
            animation?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            animation!.center = CGPoint(x: animationBackgroundView!.bounds.size.width/2, y: animationBackgroundView!.bounds.size.height/2)
            
//            animation?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            animationBackgroundView!.addSubview(animation!)
            self.playLoader()
        }
    }
    
    func playLoader() {
        animation?.play(completion: { finished in
            
            if(finished && BODataManager.shared().assets == nil) {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                    self.playLoader()
                })
                
            }
            else {
                self.animationBackgroundView!.removeFromSuperview()
            }
        })
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(BODataManager.shared().assets == nil) {
            return 0
        }
        return BODataManager.shared().assets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = BOAssetTableViewCell.init(style: .default, reuseIdentifier: nil)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MarginalAssetPairCellId", for: indexPath) as! LWMarginalAssetPairTableViewCell

        
        
        let asset = BODataManager.shared().assets[indexPath.row] as! BOAsset
        
        cell.asset = asset
        
//        cell.textLabel?.text = asset.identity
//        cell.selectionStyle = .none
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = BOGamePresenter(nibName: "BOGamePresenter", bundle: Bundle.main)
            
            //Bundle.main.loadNibNamed("BOGamePresenter", owner: self, options: nil) as! BOGamePresenter
        game.asset = BODataManager.shared().assets![indexPath.row] as! BOAsset
        BODataManager.shared().sendGameStartedEvent(game.asset)
        
//        let transition = CATransition()
//        transition.duration = 0.25
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        view.window!.layer.add(transition, forKey: kCATransition)
//        present(game, animated: false, completion: nil)
        
        self.navigationController?.pushViewController(game, animated: true)
//        self.present(game, animated: true, completion: nil)
    }
    
    func assetsListChanged() {
        tableView?.reloadData()
    }
    
    func pricesChanged() {
        tableView?.reloadData()

    }
    
    open override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
}


class BOAssetTableViewCell: UITableViewCell {
    
}
