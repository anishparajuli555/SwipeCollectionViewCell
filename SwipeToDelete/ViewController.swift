//
//  ViewController.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var panGesture = UIPanGestureRecognizer()
    let kBounceValue:CGFloat = 0
    var swipeActiveCell:CustomCollectionViewCell?
    var numberOfCell = 30
    
    
    //MARK: VIEW LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flow.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10)
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panThisCell))
        panGesture.delegate = self
        self.collectionView.addGestureRecognizer(panGesture)
        
    }
    
}

//MARK:COLLECTION VIEW DATA SOURCE
extension ViewController:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return numberOfCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        cell.customTextLbl.text = "Swipe To Delete"
        cell.delegate = self
        return cell
    }
}

//MARK:COLLECTION VIEW DELEGATE FLOW LAYOUT
extension ViewController:UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.frame.size.width - 10 * 4) / 3
        return CGSize(width: width, height: 150)
        
    }
}

//MARK:SENDCOMMAND DELEGATE
extension ViewController:SendCommandToVC{
    
    func deleteThisCell(){
        
        numberOfCell = numberOfCell  - 1
        let indexpath = self.collectionView.indexPath(for: swipeActiveCell!)
        self.collectionView.deleteItems(at: [indexpath!])
        
    }
}

//MARK:GESTURE RECONIZER DELEGATE FLOW LAYOUT
extension ViewController:UIGestureRecognizerDelegate{
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        //IF FALSE DISABLED COLLECTIONVIEW VERTICAL SCROLLING
        return true
    }
    
}


//MARK: PAN GESTURE METHODS
extension ViewController{
    
    func panThisCell(_ recognizer:UIPanGestureRecognizer){
        
        if recognizer != panGesture{  return }
        
        let point = recognizer.location(in: self.collectionView)
        let indexpath = self.collectionView.indexPathForItem(at: point)
        if indexpath == nil{  return }
        guard let cell = self.collectionView.cellForItem(at: indexpath!) as? CustomCollectionViewCell else{
            
            return
            
        }
        switch recognizer.state {
        case .began:
            
            cell.startPoint =  self.collectionView.convert(point, to: cell)
            cell.startingRightLayoutConstraintConstant  = cell.contentViewRightConstraint.constant
            if swipeActiveCell != cell && swipeActiveCell != nil{
                
                self.resetConstraintToZero(swipeActiveCell!,animate: true, notifyDelegateDidClose: false)
            }
            swipeActiveCell = cell
            
        case .changed:
            
            let currentPoint =  self.collectionView.convert(point, to: cell)
            let deltaX = currentPoint.x - cell.startPoint.x
            var panningleft = false
            
            if currentPoint.x < cell.startPoint.x{
                
                panningleft = true
                
            }
            if cell.startingRightLayoutConstraintConstant == 0{
                
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
                        cell.contentViewLeftConstraint.constant = -constant
                    }
                }
            }else{
                
                let adjustment = cell.startingRightLayoutConstraintConstant - deltaX;
                if (!panningleft) {
                    
                    let constant = max(adjustment, 0);
                    if (constant == 0) {
                        
                        self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: false)
                        
                    } else {
                        
                        cell.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    let constant = min(adjustment, self.getButtonTotalWidth(cell));
                    if (constant == self.getButtonTotalWidth(cell)) {
                        
                        self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: false)
                    } else {
                        
                        cell.contentViewRightConstraint.constant = constant;
                    }
                }
                cell.contentViewLeftConstraint.constant = -cell.contentViewRightConstraint.constant;
                
            }
            cell.layoutIfNeeded()
        case .cancelled:
            
            if (cell.startingRightLayoutConstraintConstant == 0) {
                
                self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)
                
            } else {
                
                self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
            }
            
        case .ended:
            
            if (cell.startingRightLayoutConstraintConstant == 0) {
                //Cell was opening
                let halfOfButtonOne = (cell.swipeView.frame).width / 2;
                if (cell.contentViewRightConstraint.constant >= halfOfButtonOne) {
                    //Open all the way
                    self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
                } else {
                    //Re-close
                    self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)
                }
            } else {
                //Cell was closing
                let buttonOnePlusHalfOfButton2 = (cell.swipeView.frame).width
                if (cell.contentViewRightConstraint.constant >= buttonOnePlusHalfOfButton2) {
                    //Re-open all the way
                    self.setConstraintsToShowAllButtons(cell,animate: true, notifyDelegateDidOpen: true)
                } else {
                    //Close
                    self.resetConstraintToZero(cell,animate: true, notifyDelegateDidClose: true)
                }
            }
            
        default:
            print("default")
        }
    }
    func getButtonTotalWidth(_ cell:CustomCollectionViewCell)->CGFloat{
        
        let width = cell.frame.width - cell.swipeView.frame.minX
        return width
        
    }
    
    func resetConstraintToZero(_ cell:CustomCollectionViewCell, animate:Bool,notifyDelegateDidClose:Bool){
        
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
        cell.startPoint = CGPoint()
        swipeActiveCell = nil
    }
    
    func setConstraintsToShowAllButtons(_ cell:CustomCollectionViewCell, animate:Bool,notifyDelegateDidOpen:Bool){
        
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
    
    func setConstraintsAsSwipe(_ cell:CustomCollectionViewCell, animate:Bool,notifyDelegateDidOpen:Bool){
        
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
    
    
    func updateConstraintsIfNeeded(_ cell:CustomCollectionViewCell, animated:Bool,completionHandler:@escaping ()->()) {
        var duration:Double = 0
        if animated{
            
            duration = 0.1
            
        }
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseOut], animations: {
            
            cell.layoutIfNeeded()
            
            }, completion:{ value in
                
                if value{ completionHandler() }
        })
    }
}
