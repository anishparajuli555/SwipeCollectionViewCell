//
//  SecondViewController.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var panGesture = UIPanGestureRecognizer()
    let kBounceValue:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        // Do any additional setup after loading the view.
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panThisCell))
        // panGesture.delegate = self
        self.collectionView.addGestureRecognizer(panGesture)
        
    }
    
    func panThisCell(recognizer:UIPanGestureRecognizer){
        
        let point = recognizer.locationInView(self.collectionView)
        print(point)
        
        
        //convert this point to collectionview cell coordinate
        let indexpath = self.collectionView.indexPathForItemAtPoint(point)
        if indexpath == nil{  return }
        guard let cell = self.collectionView.cellForItemAtIndexPath(indexpath!) as? TileCollectionViewCell else{
            return
        }
        switch recognizer.state {
        case .Began:
            
           // let convertpoint =
           /// print("converted point is \(convertpoint)")
            cell.startPoint =  self.collectionView.convertPoint(point, toView: cell.customContentView)
            cell.startingRightLayoutConstraintConstant  = cell.contentViewRightConstraint.constant
            
        case .Changed:
            
            let currentPoint =  self.collectionView.convertPoint(point, toView: cell.customContentView)
            let deltaX = currentPoint.x - cell.startPoint.x
            var panningleft = false
            
            if currentPoint.x < cell.startPoint.x{
                
                panningleft = true
            }
            
            if cell.startingRightLayoutConstraintConstant == 0{
                
                //cell openinig first time
                if !panningleft{
                    
                    let constant = max(-deltaX,0)
                    if constant == 0{
                        
                        self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: false)
                        
                    }else{
                        
                        cell.contentViewRightConstraint.constant = constant
                        
                    }
                }else{
                    
                    let constant = min(-deltaX,self.getButtonTotalWidth(cell))
                    if constant == self.getButtonTotalWidth(cell){
                        
                        self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: false)
                        
                    }else{
                        
                        cell.contentViewRightConstraint.constant = constant
                    }
                }
            }else{
                
                let adjustment = cell.startingRightLayoutConstraintConstant - deltaX; //1
                if (!panningleft) {
                    
                    let constant = max(adjustment, 0); //2
                    if (constant == 0) {
                        
                        self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: false)
                        
                    } else { //4
                        
                        cell.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    let constant = min(adjustment, self.getButtonTotalWidth(cell)); //5
                    if (constant == self.getButtonTotalWidth(cell)) { //6
                        
                        self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: false)
                    } else { //7
                        
                        cell.contentViewRightConstraint.constant = constant;
                    }
                }
                cell.contentViewLeftConstraint.constant = -cell.contentViewRightConstraint.constant;
                
            }
            
        case .Cancelled:
            
            if (cell.startingRightLayoutConstraintConstant == 0) {
                
                self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)//Cell was closed - reset everything to 0
                
            } else {
                self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
            }
            print("cancelled")
            
        case .Ended:
            
            if (cell.startingRightLayoutConstraintConstant == 0) { //1
                //Cell was opening
                let halfOfButtonOne = CGRectGetWidth(cell.swipeView.frame) / 2; //2
                if (cell.contentViewRightConstraint.constant >= halfOfButtonOne) { //3
                    //Open all the way
                    self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
                } else {
                    //Re-close
                    self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)
                }
            } else {
                //Cell was closing
                let buttonOnePlusHalfOfButton2 = CGRectGetWidth(cell.swipeView.frame)//4
                if (cell.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) { //5
                    //Re-open all the way
                    self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
                } else {
                    //Close
                    self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)
                }
            }
            
            
            print("gesture ended")
            
        default:
            print("default")
        }
    }
    
    
    func getButtonTotalWidth(cell:TileCollectionViewCell)->CGFloat{
        
        let width = CGRectGetWidth(cell.frame) - CGRectGetMinX(cell.swipeView.frame)
        return width
        
    }
    
    func resetConstraintToZero(cell:TileCollectionViewCell, animate:Bool,notifyDelegateDidClose:Bool){
        
        if (cell.startingRightLayoutConstraintConstant == 0 &&
            cell.contentViewRightConstraint.constant == 0) {
            //Already all the way closed, no bounce necessary
            return;
        }
        cell.contentViewRightConstraint.constant = -kBounceValue;
        cell.contentViewLeftConstraint.constant = kBounceValue;
        self.updateConstraintsIfNeeded(cell,animated: animate) {
            cell.contentViewRightConstraint.constant = 0;
            cell.contentViewLeftConstraint.constant = 0;
            
            self.updateConstraintsIfNeeded(cell,animated: animate, completionHandler: {
                
                cell.startingRightLayoutConstraintConstant = cell.contentViewRightConstraint.constant;
            })
        }
    }
    
    func setConstraintsToShowAllButtons(cell:TileCollectionViewCell, animate:Bool,notifyDelegateDidOpen:Bool){
        
        if (cell.startingRightLayoutConstraintConstant == self.getButtonTotalWidth(cell) &&
            cell.contentViewRightConstraint.constant == self.getButtonTotalWidth(cell)) {
            return;
        }
        cell.contentViewLeftConstraint.constant = -self.getButtonTotalWidth(cell) - kBounceValue;
        cell.contentViewRightConstraint.constant = self.getButtonTotalWidth(cell) + kBounceValue;
        
        self.updateConstraintsIfNeeded(cell,animated: animate) {
            cell.contentViewLeftConstraint.constant =  -(self.getButtonTotalWidth(cell))
            cell.contentViewRightConstraint.constant = self.getButtonTotalWidth(cell)
            
            self.updateConstraintsIfNeeded(cell,animated: animate, completionHandler: {(check) in
                
                cell.startingRightLayoutConstraintConstant = cell.contentViewRightConstraint.constant;
            })
        }
    }
    
    func updateConstraintsIfNeeded(cell:TileCollectionViewCell, animated:Bool,completionHandler:()->()) {
        var duration:Double = 0
        if animated{
            
            duration = 0.1
            
        }
        UIView.animateWithDuration(duration, delay: 0, options: [.CurveEaseOut], animations: {
            
            cell.layoutIfNeeded()
            
            }, completion:{ value in
                
                if value{ completionHandler() }
        })
    }
    
    
}
//MARK:COLLECTION VIEW DATA SOURCE
extension SecondViewController:UICollectionViewDataSource{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! TileCollectionViewCell
        cell.customTextLbl.text = "Swipe To Delete"
        return cell
    }
}
extension SecondViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        
        let width = (self.view.frame.size.width - 10 * 4) / 3
        return CGSize(width: width, height: 150)
        
    }
}
