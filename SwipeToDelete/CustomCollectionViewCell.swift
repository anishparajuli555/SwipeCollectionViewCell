//
//  CustomCollectionViewCell.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

protocol SendCommandToVC{
    
    func deleteThisCell()
    
}


class CustomCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var customTextLbl: UILabel!
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    
    var delegate:SendCommandToVC?
    
    var startPoint = CGPoint()
    var startingRightLayoutConstraintConstant = CGFloat()
    
    @IBAction func unpinThisUnit(_ sender: AnyObject) {
        if let temp = delegate{
            
            temp.deleteThisCell()
            
        }else{
            
            print("you forgot to set the delegate")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
