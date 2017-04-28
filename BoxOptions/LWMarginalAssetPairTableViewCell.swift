//
//  LWMarginalAssetPairTableViewCell.swift
//  LykkeWallet
//
//  Created by Andrey Snetkov on 13/12/2016.
//  Copyright © 2016 Lykkex. All rights reserved.
//

import Foundation
import UIKit


class LWMarginalAssetPairTableViewCell: UITableViewCell {
    
    var _changes:NSArray=[]
    var changes:NSArray {
        get {
            return _changes
        }
        set(newValue) {
            _changes=newValue
            changeView?.changes=_changes as! [Any]
            changeView?.setNeedsDisplay()
            
        }
    }
    
    var _asset:BOAsset?
    var asset:BOAsset {
        get {
            return _asset!
        }
        set {
            _asset=newValue
            
            let yyy = _asset!.rate
            let yy1 = _asset!.accuracy
            let iii=_asset?.identity
            
            askLabel?.text = String(asset.rate.ask)
            bidLabel?.text = String(asset.rate.bid)
            
//            let greenColor=UIColor(red: 19.0/255, green: 183.0/255, blue: 42.0/255, alpha: 1)
//            let redColor=UIColor(red: 255.0/255, green: 62.0/255, blue: 46.0/255, alpha: 1)
//            
            if(_asset!.previousRate != nil)
            {
                if(_asset!.askRaising)
                {
//                    askLabel?.textColor=greenColor
                    askArrow?.image = #imageLiteral(resourceName: "ArrowUp")
                }
                else
                {
//                    askLabel?.textColor=redColor
                    askArrow?.image = #imageLiteral(resourceName: "ArrowDown")
                }
                
                if(_asset!.bidRaising)
                {
//                    bidLabel?.textColor=greenColor
                    bidArrow?.image = #imageLiteral(resourceName: "ArrowUp")
                }
                else
                {
                    //bidLabel?.textColor=redColor
                    bidArrow?.image = #imageLiteral(resourceName: "ArrowDown")
                }
                
            }
            
//            leverageLabel!.text="lvg 1:"+String(Int(_asset!.leverage))
            
            name?.text=_asset!.identity
            changes=_asset!.graphValues as NSArray
            changeView?.setNeedsDisplay()
        }
        
    }
    
    
    @IBOutlet private weak var askLabel:UILabel?
    @IBOutlet private weak var bidLabel:UILabel?
    @IBOutlet private weak var name:UILabel?
    @IBOutlet private weak var changeView:LWAssetLykkeTableChangeView?
    @IBOutlet private weak var leverageLabel:UILabel?
    @IBOutlet private weak var checkmark:UIImageView?
    
    @IBOutlet private weak var askArrow: UIImageView?
    @IBOutlet private weak var bidArrow: UIImageView?
    
    @IBOutlet private weak var checkmarkContainerWidthConstraint:NSLayoutConstraint?
    
    private var _checkMarkIsOn:Bool?
    var checkMarkIsOn:Bool {
        set {
            _checkMarkIsOn = newValue
            if(_checkMarkIsOn == true) {
                checkmark?.image = #imageLiteral(resourceName: "SquareCheckmarkOn")
            }
            else {
                checkmark?.image = #imageLiteral(resourceName: "SquareCheckmarkOff")
            }
        }
        get {
            if(_checkMarkIsOn == nil) {
                return false
            }
            return _checkMarkIsOn!
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle=UITableViewCellSelectionStyle.none
        changeView?.defaultColor=UIColor(red: 13.0/255, green: 167.0/255, blue: 252.0/255, alpha: 1)
        
        
        adjustThinLines()
//        fixLabelColors()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    
    func setShouldShowCheckMark(flag: Bool) {
        if(flag == true) {
            changeView?.isHidden = true
            checkmarkContainerWidthConstraint?.constant = 28
            checkmark?.isHidden = false
        }
        else {
            changeView?.isHidden = false
            checkmark?.isHidden = true
            checkmarkContainerWidthConstraint?.constant = 0
        }
    }
    
}
