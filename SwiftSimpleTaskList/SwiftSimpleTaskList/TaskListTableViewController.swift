//
//  TaskListTableViewController.swift
//  SwiftSimpleTaskList
//
//  Created by Prashant on 04/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit
import CoreData

class TaskListTableViewController: UITableViewController, TaskDelegate {

    
    // task list - will be loaded from core data
    var taskList = [Task]()
    
    
    // index for currently edited task
    // value will be set when user click record and go to edit screen.
    var updatedTaskIndex: Int = -1

    
    // outlet and action - Edit button
    @IBOutlet var editButton: UIBarButtonItem!
    @IBAction func editButtonClicked(sender: UIBarButtonItem) {
        self.toggleTableEditingMode()
    }
    
    
    // outlet and action - task add button
    @IBOutlet var taskAddButton: UIBarButtonItem!
    @IBAction func taskAddButtonClicked(sender: UIBarButtonItem) {
        // go to task add screen
        self.performSegueWithIdentifier("segueTaskAdd", sender: self)
    }
    
    
    
    
    // MARK: - View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // clear selection when view will appear
        self.clearsSelectionOnViewWillAppear = true
        
        // add pull to refresh functionality within table view
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshData:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        // load task from core data
        self.loadTaskData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // pull to refresh handler
    func refreshData(refreshControl: UIRefreshControl) {

        // reload task from core data
        self.loadTaskData()
        
        // hide refreshing icon
        refreshControl.endRefreshing()
    }
    
    
    
    
    // MARK: - Table view dataSource and delegate function
    
    // numner of section in table
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    // return row height
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    // return record count
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return self.taskList.count
    }
    
    // return cell for given row
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // deque reusable cell
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCellTableViewCell

        // Configure the cell content
        cell.Title.text = self.taskList[indexPath.row].title
        cell.colorPreview.backgroundColor = UtilityManager.sharedInstance.convertHexToUIColor(hexColor: self.taskList[indexPath.row].color)

        // return cell
        return cell
    }
    
    // support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // enable editing supprt for table row.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

        if editingStyle == .Delete {
            
            // delete record from core data, 
            // then remove row from tableView and taskList array
            self.deleteTaskRecord(indexPath)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            // This functionality Not implemented yet. Keep this for future updates purpose.
        }
    }
    
    // go to edit screen upon row selection.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // set updated task index ( used within task update delegate function)
        self.updatedTaskIndex = indexPath.row
        
        // deselect table row
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // go to edit screen
        self.performSegueWithIdentifier("segueTaskEdit", sender: self)
    }
    
    /*
    // This functionality will be added in future updates.
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    }
    */

    /*
    //This functionality will be added in future updates.
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    
    
    // MARK: Task Delegate function
    
    // called when new task added
    func taskDidAdd(newTask: Task) {
        
        // insert new task at top
        self.taskList.insert(newTask, atIndex: 0)

        // refresh table view
        self.tableView.reloadData()
        
        // disable edit button if no record
        self.enableDisableEditButton()
    }
    
    // called when task updated
    func taskDidUpdate(updatedTask: Task) {
        
        // if task in edit mode
        if self.updatedTaskIndex >= 0 {
            
            // remove old task record
            self.taskList.removeAtIndex(self.updatedTaskIndex)
            
            // add updated task record
            self.taskList.insert(updatedTask, atIndex: self.updatedTaskIndex)

            // refresh table
            self.tableView.reloadData()
        }
    }
    
    
    
    
    // MARK: - Utility functions
    
    // toggle table editing mode
    private func toggleTableEditingMode() {
        if self.tableView.editing == true {
            self.editButton.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        }else{
            self.editButton.title = "Done"
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    // disable edit button if no record
    func enableDisableEditButton() {
        if self.taskList.count == 0 {
            self.editButton.enabled = false
        }else{
            self.editButton.enabled = true
        }
    }
    
    // load task list from core data
    private func loadTaskData(){
    
        // 1 - create managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        // 2 - create fetch request
        let fetchRequest = NSFetchRequest(entityName:"Task")
        
        // 3 - set predicate ( search criteria ) [NOT USED AT PRESENT]
        //let myPredicate: NSPredicate = NSPredicate(format: "color != %@", argumentArray: ["#FF0000"])
        //fetchRequest.predicate = myPredicate
        
        // 4 - set sort descriptor, show recently added record at top
        let mySortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "dateAdded", ascending: false)
        fetchRequest.sortDescriptors = [mySortDescriptor]
        
        // 5 - fetch records
        var error: NSError?
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject]
        
        // 6 - if records found then assign to array
        if let results = fetchedResults {
            
            // make task list empty (important)
            self.taskList.removeAll(keepCapacity: false)
            
            // assign received records to taskList
            self.taskList = results as! [Task]
            
        }else{
            self.showAlertMessage(alertTitle: "Data Fetch Error", alertMessage: error!.localizedDescription)
        }
        
        // 7 - reload table
        self.tableView.reloadData()
        
        // 8 - diable edit button if no record
        self.enableDisableEditButton()
    }
    
    // delete task record from core data.
    func deleteTaskRecord(indexPath: NSIndexPath){
        
        // 1 - find which record to be deleted
        var taskToDelete = self.taskList[indexPath.row]
        
        // 2 - Delete record via managedObjectContext
        let myAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let myManagedObjectContext = myAppDelegate.managedObjectContext!
        myManagedObjectContext.deleteObject(taskToDelete)
     
        // 3 - Save context after delete
        var error : NSError?
        if( myManagedObjectContext.save(&error) ) {
            
            // if no error then remove record from table and array
            if error != nil{
                
                // show error message
                self.showAlertMessage(alertTitle: "Delete Error!", alertMessage: error!.localizedDescription)
            }else{
                
                // delete record from task list array
                self.taskList.removeAtIndex(indexPath.row)
                
                // delete table row with animation
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                
                // it no record then toggle table editing mode
                if self.tableView.editing &&  self.taskList.count == 0 {
                    self.toggleTableEditingMode()
                }
                
                // disable edit button if no record
                self.enableDisableEditButton()
            }
        }
        
    }
    
    // show alert message with OK button
    func showAlertMessage( #alertTitle: String, alertMessage: String) {
        
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        
        myAlertVC.addAction(okAction)
        
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
    
    
    
    
    // MARK: - Navigation

    // prepare data befor seguae operation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // for task add
        if segue.identifier == "segueTaskAdd" {
            
            // create destination view controller object
            let destVc = segue.destinationViewController  as! TaskAddViewController
            
            // set task delegate
            destVc.taskDelegate = self
        }
        
        // for task edit
        if segue.identifier == "segueTaskEdit" {
            
            // create destination view controller object
            let destVc = segue.destinationViewController  as! TaskEditViewController
            
            // set task object to be edite.
            destVc.selectedTask = self.taskList[self.updatedTaskIndex]

            // set task delegate
            destVc.taskDelegate = self
        }
    }


}
