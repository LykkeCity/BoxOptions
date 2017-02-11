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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(assetsListChanged), name: NSNotification.Name("AssetsListChanged"), object: nil)
        
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = BOAssetTableViewCell.init(style: .default, reuseIdentifier: nil)
        
        let asset = BODataManager.shared().assets[indexPath.row] as! BOAsset
        cell.textLabel?.text = asset.identity
        
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
    
}


class BOAssetTableViewCell: UITableViewCell {
    
}
