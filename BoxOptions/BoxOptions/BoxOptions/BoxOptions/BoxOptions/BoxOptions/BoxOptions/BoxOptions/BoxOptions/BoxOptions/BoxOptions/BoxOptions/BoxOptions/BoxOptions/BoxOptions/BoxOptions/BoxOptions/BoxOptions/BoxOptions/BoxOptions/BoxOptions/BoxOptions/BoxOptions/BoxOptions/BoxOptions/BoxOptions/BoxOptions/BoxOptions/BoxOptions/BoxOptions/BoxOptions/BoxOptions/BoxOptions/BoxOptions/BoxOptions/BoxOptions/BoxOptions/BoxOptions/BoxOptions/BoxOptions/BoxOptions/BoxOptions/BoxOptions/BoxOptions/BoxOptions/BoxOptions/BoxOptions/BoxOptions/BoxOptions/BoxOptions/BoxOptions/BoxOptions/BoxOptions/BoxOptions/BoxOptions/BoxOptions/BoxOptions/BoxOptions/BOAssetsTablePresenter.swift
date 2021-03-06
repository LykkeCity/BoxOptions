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
    
    var animation: LOTAnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(assetsListChanged), name: NSNotification.Name("AssetsListChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pricesChanged), name: NSNotification.Name("PricesChanged"), object: nil)
        
        tableView?.register(UINib(nibName: "LWMarginalAssetPairTableViewCell", bundle: nil), forCellReuseIdentifier: "MarginalAssetPairCellId")
        tableView?.separatorStyle = .none
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if(animation == nil) {
//            animation = LOTAnimationView.animationNamed("box_loader.json")
            animation = LOTAnimationView(name: "box_loader.json")
            animation?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            animation!.center = self.view.center
            animation?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            self.view.addSubview(animation!)
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
                self.animation?.removeFromSuperview()
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
        return 65
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
        
        self.present(game, animated: true, completion: nil)
    }
    
    func assetsListChanged() {
        tableView?.reloadData()
    }
    
    func pricesChanged() {
        tableView?.reloadData()

    }
    
//    open override var shouldAutorotate: Bool {
//        get {
//            return false
//        }
//    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
}


class BOAssetTableViewCell: UITableViewCell {
    
}
