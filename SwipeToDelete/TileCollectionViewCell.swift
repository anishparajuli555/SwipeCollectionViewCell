//
//  TileCollectionViewCell.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

protocol UnPin{

    func unPintThisUnit()

}


class TileCollectionViewCell: UICollectionViewCell,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var swipeView: UIView!
    @IBOutlet weak var customTextLbl: UILabel!
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    
    var delegate:UnPin?
   
    var startPoint = CGPoint()
    var startingRightLayoutConstraintConstant = CGFloat()
    
    @IBAction func unpinThisUnit(sender: AnyObject) {
        
        delegate?.unPintThisUnit()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
