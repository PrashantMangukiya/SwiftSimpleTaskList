//
//  TaskAddViewController.swift
//  SwiftSimpleTaskList
//
//  Created by Prashant on 04/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit
import CoreData

// Define global array for color , used within view controller whenever need
var ARRAY_COLOR_LIST_TITLE: [String] = ["(( Choose Color ))", "Red", "Green", "Blue", "Yellow", "Pink", "Black"]
var ARRAY_COLOR_LIST_VALUE: [String] = ["#FFFFFF", "#FF0000", "#00FF00", "#0000FF", "#FFFF00", "#FF80BF", "#000000"]


// define protocol for task function
protocol TaskDelegate {
    
    // for new task added, newly added task object passed
    func taskDidAdd(newTask: Task)
    
    // for task updated, updated task object passed
    func taskDidUpdate(updatedTask: Task)
}


class TaskAddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    // task delegate variable
    var taskDelegate : TaskDelegate?
        
    // define color list array (used to fillup colorPicker)
    var colorListTitle: [String] = ARRAY_COLOR_LIST_TITLE
    var colorListValue: [String] = ARRAY_COLOR_LIST_VALUE
    
    // outlet and action - Cancel button
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem) {
        self.goBack()
    }
        
    // outlet and action - Save button button
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBAction func saveButtonClicked(sender: UIBarButtonItem) {
        self.saveRecord()
    }
    
    // outlet - task title
    @IBOutlet var taskTitle: UITextField!
    @IBAction func taskTitleEditingChanged(sender: UITextField) {
        self.validateInputData()
    }
    
    // outlet - colorPickerView
    @IBOutlet var colorPicker: UIPickerView!
        
    // outlet - task color preview circle
    @IBOutlet var colorPreview: UIView!
    
    // task color that stores color in hex
    var taskColor: String? {
        didSet{
            // set preview color whenever taskColor value change
            self.colorPreview?.backgroundColor = UtilityManager.sharedInstance.convertHexToUIColor(hexColor: self.taskColor!)
        }
    }
    
    
        
    
    // MARK: - View functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // setup initial view
        self.setupInitialView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: Textfield delegate
    
    // remove editing mode from text box and close keyboard when touched anywhere on a screen
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.validateInputData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    // MARK: UIPicker View Delegate
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.colorListTitle.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.colorListTitle[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // close keyboard if open
        self.view.endEditing(true)

        // set task color
        self.taskColor = self.colorListValue[row]
        
        // if input not valid then disable save button.
        self.validateInputData()
    }
    
    
    
    
    // MARK: Utility function
    
    // setup initial view
    private func setupInitialView(){
        
        // set text field delegate
        self.taskTitle.delegate = self
        
        // set colorPicker delegate and dataSource
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        
        // make color preview box circle
        self.colorPreview.layer.cornerRadius = self.colorPreview.frame.width/2
        
        // set default value for colorPicker and task color
        self.taskColor = "#FFFFFF"  // set white
        self.colorPicker.selectRow(0, inComponent: 0, animated: true)  // select first row
        
        // disable save button if not valid input
        self.validateInputData()
    }
    
    // validate input data.
    // i.e. disable save button if task title and task color value not set.
    private func validateInputData() {
    
        var isValidData: Bool = true
        
        if self.taskTitle.text == "" {
            isValidData = false
        }else if self.taskColor == "" || self.taskColor == "#FFFFFF" {
            isValidData = false
        }
        
        if isValidData {
            self.saveButton.enabled = true
        }else{
            self.saveButton.enabled = false
        }
        
    }
    
    // add record to core database and go to back screen
    private func saveRecord(){
        
        // Step 1: get managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!

        // Step 2: Create entity for table
        let entityTask =  NSEntityDescription.entityForName("Task", inManagedObjectContext: managedObjectContext)
        
        // Step 3: create empty Task record
        let taskRecord = Task(entity: entityTask!, insertIntoManagedObjectContext: managedObjectContext )
        
        // Step 4: Set value within empty record
        taskRecord.title = self.taskTitle.text!
        taskRecord.color = self.taskColor!
        taskRecord.dateAdded = NSDate() // i.e. current date
        
        
        do {
            // Step 5: save record
            try managedObjectContext.save()

            // Step 6: call task delegate function
            self.taskDelegate?.taskDidAdd(taskRecord)
            
            // Step 7: Go to back screen
            self.goBack()
            
        } catch let error as NSError {
            self.showAlertMessage(alertTitle: "Save Error", alertMessage: error.localizedDescription)
        }
        
    }
    
    // go to back scren
    private func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // show alert message with OK button
    private func showAlertMessage( alertTitle alertTitle: String, alertMessage: String) {
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlertVC.addAction(okAction)
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
                
}

