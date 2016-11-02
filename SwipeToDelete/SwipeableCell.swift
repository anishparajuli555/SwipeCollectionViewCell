//
//  SwipeableCell.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

protocol CellSwipeDelegateActn {
    
    func deleteButtonPressed()
}


class SwipeableCell: UITableViewCell {
    
    var delegate:CellSwipeDelegateActn?
    
    let kBounceValue:CGFloat = 0
    
    @IBOutlet weak var customTextLbl: UILabel!
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var swipeBtn: UIButton!
    @IBAction func swipeToDelete(sender: AnyObject) {
        
        delegate?.deleteButtonPressed()
        
    }
    
    var panGesture = UIPanGestureRecognizer()
    var startPoint = CGPoint()
    var startingRightLayoutConstraintConstant = CGFloat()
    @IBOutlet weak var contentViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewRightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetConstraintToZero(false, notifyDelegateDidClose: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(SwipeableCell.panThisCell))
        panGesture.delegate = self
        self.customContentView.addGestureRecognizer(panGesture)
        
    }
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
        
    }
    
    func panThisCell(recognizer:UIPanGestureRecognizer){
        
        switch recognizer.state {
        case .Began:
            
            self.startPoint = recognizer.translationInView(self.customContentView)
            self.startingRightLayoutConstraintConstant  = self.contentViewRightConstraint.constant
            
        case .Changed:
            
            let currentPoint = recognizer.translationInView(self.customContentView)
            let deltaX = currentPoint.x - self.startPoint.x
            var panningleft = false
            
            if currentPoint.x < self.startPoint.x{
                
                panningleft = true
            }
            
            if self.startingRightLayoutConstraintConstant == 0{
                
                //cell openinig first time
                if !panningleft{
                    
                    let constant = max(-deltaX,0)
                    if constant == 0{
                        
                        self.resetConstraintToZero(true, notifyDelegateDidClose: false)
                        
                    }else{
                        
                        self.contentViewRightConstraint.constant = constant
                        
                    }
                }else{
                    
                    let constant = min(-deltaX,self.getButtonTotalWidth())
                    if constant == self.getButtonTotalWidth(){
                        
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                        
                    }else{
                        
                        self.contentViewRightConstraint.constant = constant
                    }
                }
            }else{
                
                let adjustment = self.startingRightLayoutConstraintConstant - deltaX; //1
                if (!panningleft) {
                    
                    let constant = max(adjustment, 0); //2
                    if (constant == 0) {
                        
                        self.resetConstraintToZero(true, notifyDelegateDidClose: false)
                        
                    } else { //4
                        
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    let constant = min(adjustment, self.getButtonTotalWidth()); //5
                    if (constant == self.getButtonTotalWidth()) { //6
                        
                        self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: false)
                    } else { //7
                        
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
                
            }
            
        case .Cancelled:
            
            if (self.startingRightLayoutConstraintConstant == 0) {
                
                self.resetConstraintToZero(true, notifyDelegateDidClose: true)//Cell was closed - reset everything to 0
                
            } else {
                self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
            }
            print("cancelled")
            
        case .Ended:
            
            if (self.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                let halfOfButtonOne = CGRectGetWidth(self.swipeBtn.frame) / 2; //2
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                } else {
                    //Re-close
                    self.resetConstraintToZero(true, notifyDelegateDidClose: true)
                }
            } else {
                //Cell was closing
                let buttonOnePlusHalfOfButton2 = CGRectGetWidth(self.swipeBtn.frame)//4
                if (self.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    self.setConstraintsToShowAllButtons(true, notifyDelegateDidOpen: true)
                } else {
                    //Close
                    self.resetConstraintToZero(true, notifyDelegateDidClose: true)
                }
            }
            
            
            print("gesture ended")
            
        default:
            print("default")
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func getButtonTotalWidth()->CGFloat{
        
        let width = CGRectGetWidth(self.frame) - CGRectGetMinX(self.swipeBtn.frame)
        return width
        
    }
    
    func resetConstraintToZero(animate:Bool,notifyDelegateDidClose:Bool){
        
        if (self.startingRightLayoutConstraintConstant == 0 &&
            self.contentViewRightConstraint.constant == 0) {
            //Already all the way closed, no bounce necessary
            return;
        }
        self.contentViewRightConstraint.constant = -kBounceValue;
        self.contentViewLeftConstraint.constant = kBounceValue;
        self.updateConstraintsIfNeeded(animate) {
            self.contentViewRightConstraint.constant = 0;
            self.contentViewLeftConstraint.constant = 0;
            
            self.updateConstraintsIfNeeded(animate, completionHandler: {
                
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            })
        }
        
    }
    
    func setConstraintsToShowAllButtons(animate:Bool,notifyDelegateDidOpen:Bool){
        
        if (self.startingRightLayoutConstraintConstant == self.getButtonTotalWidth() &&
            self.contentViewRightConstraint.constant == self.getButtonTotalWidth()) {
            return;
        }
        self.contentViewLeftConstraint.constant = -self.getButtonTotalWidth() - kBounceValue;
        self.contentViewRightConstraint.constant = self.getButtonTotalWidth() + kBounceValue;
        
        self.updateConstraintsIfNeeded(animate) {
            self.contentViewLeftConstraint.constant =  -(self.getButtonTotalWidth())
            self.contentViewRightConstraint.constant = self.getButtonTotalWidth()
            
            self.updateConstraintsIfNeeded(animate, completionHandler: {(check) in
                
                self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            })
        }
    }
    
    func updateConstraintsIfNeeded(animated:Bool,completionHandler:()->()) {
        var duration:Double = 0
        if animated{
            
            duration = 0.1
            
        }
        UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseOut], animations: {
            
            self.layoutIfNeeded()
            
            }, completion:{ value in
                
                if value{ completionHandler() }
        })
    }
}