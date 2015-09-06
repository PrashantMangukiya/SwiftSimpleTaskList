//
//  TaskEditViewController.swift
//  SwiftSimpleTaskList
//
//  Created by Prashant on 06/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit
import CoreData


class TaskEditViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    // task delegate variable
    var taskDelegate : TaskDelegate?
    
    // define color list array (used to fillup colorPicker)
    var colorListTitle: [String] = ARRAY_COLOR_LIST_TITLE
    var colorListValue: [String] = ARRAY_COLOR_LIST_VALUE
    
    // selected task object (will be set by parent controller)
    var selectedTask: Task?
        
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
    
    // outlet and action - task title
    @IBOutlet var taskTitle: UITextField!
    @IBAction func taskTitleEditingChanged(sender: UITextField) {
        self.validateInputData()
    }
        
    // outlet - colorPickerView
    @IBOutlet var colorPicker: UIPickerView!
    
    
    // outlet - task color preview circle
    @IBOutlet var colorPreview: UIView!
    
    // task color that stores color in hex
    private var taskColor: String? {
        didSet{
            // set preview color whenever taskColor change
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
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
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
        
        // set color picker delegate and dataSource
        self.colorPicker.dataSource = self
        self.colorPicker.delegate = self
        
        // make color preview box circle
        self.colorPreview.layer.cornerRadius = self.colorPreview.frame.width/2

        // set title to text field.
        self.taskTitle.text = self.selectedTask?.title
        
        // set color within colorPicker
        self.taskColor = self.selectedTask?.color
        let colorIndex = self.getIndexForColor(colorHexValue: self.selectedTask!.color)
        self.colorPicker.selectRow(colorIndex, inComponent: 0, animated: true)  // select first row
        
        // disable save button if not valid input
        self.validateInputData()
    }
    
    // validate input data.
    // i.e. disable save button if task title and color value not set.
    private func validateInputData() {
                
        var isValidData = true
        
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
    
    // Update record within core database and go to back screen
    private func saveRecord(){
        
        // Step 1: get managed object context
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        // Step 2: Set value within empty record
        self.selectedTask?.title = self.taskTitle.text
        self.selectedTask?.color = self.taskColor!
        
        // Step 3: Save data into database
        var error: NSError?
        managedObjectContext.save(&error)
        
        // Step 4: Show error message if error generated
        if let err = error {
            // show custom error message to user
            self.showAlertMessage(alertTitle: "Update Error", alertMessage: "Error while update, please try again.")
        }else{
            
            // call task update delegate function
            self.taskDelegate?.taskDidUpdate(self.selectedTask!)
            
            // Go to back screen if no error
            self.goBack()
        }
    }
    
    
    
    
    // go to back scren
    private func goBack(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // show alert message with OK button
    private func showAlertMessage( #alertTitle: String, alertMessage: String) {
        let myAlertVC = UIAlertController( title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        myAlertVC.addAction(okAction)
        self.presentViewController(myAlertVC, animated: true, completion: nil)
    }
    
    // find our record index for give color value,
    // this function will loop through color list and return index that color match
    private func getIndexForColor(#colorHexValue: String) -> Int {
        var selectedIndex = 0
        for var i = 0 ; i < self.colorListValue.count; i++ {
            if self.colorListValue[i] == colorHexValue {
                selectedIndex = i
                break
            }
        }
        return selectedIndex
    }
    
}

