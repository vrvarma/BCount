//
//  BCountTableViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/16/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class BCountTableViewController:UIViewController, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate{
    
    var userInfo:UserInfo!
    
    @IBOutlet weak var add: UIBarButtonItem!
    @IBOutlet weak var refresh: UIBarButtonItem!
    @IBOutlet weak var activitityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [refresh,add]
        tableView.delegate = self
        
        userInfo = BCClient.sharedInstance.userInfo
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        fetchBcountData()
        tableView.reloadData()
        
    }
    
    func fetchBcountData(){
        
        self.activitityIndicator.startAnimating()
        
        
        if userInfo.counts.isEmpty {
            
            BCClient.sharedInstance.getBCountList(){ result, errorString in
                if let error = errorString  {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        BCClient.alertDialog(self, errorTitle: "Error retrieving blood counts from server", action: "Ok",errorMsg: "\(error)")
                    })
                    self.enableDisableComponents(true)
                    
                }
                else {
                    self.populateBCounts(result as? [[String: AnyObject]])
                }
                
            }
            
        }else{
            
            enableDisableComponents(false)
        }
    }
    
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    // Mark: - Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "BCount")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdDate", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "userInfo == %@", self.userInfo);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
    }()
    
    //Table view Delegate methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            
            let id = "bcountInfoCell"
            
            //print(indexPath)
            let bcount = fetchedResultsController.objectAtIndexPath(indexPath) as! BCount
            
            let cell = tableView.dequeueReusableCellWithIdentifier(id) as! BCountInfoTableViewCell
            
            // This is the new configureCell method
            configureCell(cell, bcount: bcount)
            
            return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        
        //Show the selected meme in a Detail View
        let bcount = fetchedResultsController.objectAtIndexPath(indexPath) as! BCount
        print("Update BCount \(bcount.id)")
        BCClient.sharedInstance.bcount = bcount
        let controller = storyboard!.instantiateViewControllerWithIdentifier("BCountDisplayViewController") as! BCountDisplayViewController
        controller.bcount = bcount
        
        navigationController?.pushViewController(controller, animated: true)
        print("Hello World!!")
    }
    
    func tableView(tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {
            
            switch (editingStyle) {
            case .Delete:
                let bcount = fetchedResultsController.objectAtIndexPath(indexPath) as! BCount
                //Delete it from the server
                BCClient.sharedInstance.deleteBcount(bcount.id){ result, errorString -> Void in
                    if let result = result {
                        // Here we get the bcount, then delete it from core data
                        if result == true{
                        self.sharedContext.deleteObject(bcount)
                        CoreDataStackManager.sharedInstance().saveContext()
                        }
                    }
                }
            default:
                break
            }
    }
    // MARK: - Fetched Results Controller Delegate
    
    // Step 4: This would be a great place to add the delegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as! BCountInfoTableViewCell
                let bcount = controller.objectAtIndexPath(indexPath!) as! BCount
                self.configureCell(cell, bcount: bcount)
                
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    
    // MARK: - Configure Cell
    
    func configureCell(cell: BCountInfoTableViewCell, bcount: BCount) {
        
        cell.imageView?.image = UIImage( named: "blood_drop_128")
        cell.dateLabel!.text = bcount.generateDateString()
        //cell.bcountLabel!.text = bcount.generateString()
    }
    
    private func populateBCounts(counts: [[String: AnyObject]]!)-> Void{
        
        if let countList = counts {
            
            if(countList.isEmpty){
                
                self.enableDisableComponents(true)
            }else{
                self.sharedContext.performBlockAndWait(
                    {
                        for bcountObj in countList{
                            
                            let bcount = BCount(dictionary: bcountObj, context: self.sharedContext)
                            bcount.userInfo = self.userInfo
                            
                        }
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                )
                
                self.enableDisableComponents(false)
            }
        }
    }
    
    
    //Enable disable the components based on the errorFlag
    func enableDisableComponents(errorFlag:Bool){
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.tableView.hidden = errorFlag
            self.activitityIndicator.stopAnimating()
        })
        
        
    }
    
    //Delete all photos from the sharedContext
    private func deleteAllBCounts() {
        
        for bcount in fetchedResultsController.fetchedObjects as! [BCount] {
            sharedContext.deleteObject(bcount)
        }
        CoreDataStackManager.sharedInstance().saveContext()
    }
    @IBAction func refreshData(sender: UIBarButtonItem) {
        
        self.activitityIndicator.startAnimating()
        deleteAllBCounts()
        fetchBcountData()
        
    }
    @IBAction func addNewCount(sender: UIBarButtonItem) {
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("BCountDisplayViewController") as! BCountDisplayViewController
        controller.bcount = nil
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func setEditMode(sender: UIBarButtonItem) {
        
        print(tableView.editing)
        
        if tableView.editing == true{
            
            //We're in edit mode
            //Set the tableView to non-edit mode
            tableView
                .setEditing(false, animated: true)
            sender.style = UIBarButtonItemStyle.Plain
            sender.title = "Edit"
        }
        else{
            //set the tableView to edit mode
            //change the item's title
            tableView.setEditing(true, animated: true)
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
        }
    }
}