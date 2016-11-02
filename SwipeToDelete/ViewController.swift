//
//  ViewController.swift
//  SwipeToDelete
//
//  Created by Anish on 11/2/16.
//  Copyright © 2016 Anish. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController:UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! SwipeableCell
        cell.delegate = self
        cell.customTextLbl?.text = "Swipe to delete this view"
        return cell
    }
    
        func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return false
        }
    
}

extension ViewController:CellSwipeDelegateActn{
    
    func deleteButtonPressed() {
        
        print("delete button pressed")
    }
}