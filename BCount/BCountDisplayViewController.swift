//
//  BCountEditViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/17/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import UIKit
import CoreData

class BCountDisplayViewController: UIViewController, UITextFieldDelegate{
    
    var bcount:BCount!
    
    var addFlag: Bool!
    
    var selectedDate:NSDate!
    
    @IBOutlet weak var wbcTextField: UITextField!
    @IBOutlet weak var rbcTextField: UITextField!
    @IBOutlet weak var hgbTextField: UITextField!
    
    @IBOutlet weak var plateletTextField: UITextField!
    
    @IBOutlet weak var ancTextField: UITextField!
    
    @IBOutlet weak var updateAddButton: UIButton!
    
    @IBOutlet weak var notesTextField: UITextField!
    
    @IBOutlet weak var reasonPickerView: UIPickerView!
    
    var pickerData: [String] = [String]()
    @IBOutlet weak var dateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wbcTextField.delegate = self
        rbcTextField.delegate = self
        hgbTextField.delegate = self
        plateletTextField.delegate = self
        ancTextField.delegate = self
        pickerData = ["SICK", "FOLLOW_UP", "TRANSFUSION"]
        
        dateTextField.inputAccessoryView = toolBar
        populateData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func textFieldEditing(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        
        datePickerView.datePickerMode = UIDatePickerMode.Date
        if let _ = selectedDate {
            datePickerView.date = selectedDate
        }else{
            selectedDate = NSDate()
            datePickerView.date = selectedDate
        }
        
        if dateTextField.text == "" || dateTextField == nil{
            
            selectedDate = NSDate()
            dateTextField.text = NSDateFormatter.localizedStringFromDate(selectedDate,
                dateStyle: .MediumStyle,
                timeStyle: .MediumStyle)
        }
        
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
    }
    
    
    
    func datePickerValueChanged(sender:UIDatePicker) {
        
        selectedDate = sender.date
        dateTextField.text = NSDateFormatter.localizedStringFromDate(selectedDate,
            dateStyle: .MediumStyle,
            timeStyle: .MediumStyle)
        dateTextField.resignFirstResponder()
        
    }
    override func viewDidAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
    }
    //Picker Delegate Method
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Catpure the picker view selection
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
    }
    func populateData(){
        
        if bcount != nil {
            
            addFlag = false
            selectedDate = bcount.createdDate
            dateTextField.text = NSDateFormatter.localizedStringFromDate(selectedDate,
                dateStyle: .MediumStyle,
                timeStyle: .MediumStyle)
            wbcTextField.text = "\(bcount.wbc!)"
            rbcTextField.text = "\(bcount.rbc!)"
            hgbTextField.text = "\(bcount.hgb!)"
            plateletTextField.text = "\(bcount.platelet!)"
            ancTextField.text = "\(bcount.anc!)"
            
            if let note = bcount.visitInfo?.note {
                
                notesTextField.text = note
            }else{
                
                notesTextField.text = ""
            }
            
            if let reason = bcount.visitInfo?.reason {
                
                if let result = pickerData.indexOf(reason){
                    
                    reasonPickerView.selectRow(result, inComponent: 0, animated: false)
                }
            }
            updateAddButton.setTitle("Update",forState: .Normal)
        }else{
            
            addFlag = true
            updateAddButton.setTitle("Add",forState: .Normal)
        }
    }
    @IBAction func cancelButon(sender: UIButton) {
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func updateAddBCount(sender: UIButton) {
        
        if self.addFlag == true{
            insertBcountData()
        }else{
            updateBcountData()
        }
    }
    
    func insertBcountData(){
        
        var info: [String: AnyObject]
        
        info = ["createdDate": BCClient.sharedDateFormatter.stringFromDate(selectedDate) as String,
            "userName": BCClient.sharedInstance.userId as String,
            "wbc": Double(wbcTextField.text!)!,
            "hgb":Double(hgbTextField.text!)!,
            "rbc":Double(rbcTextField.text!)!,
            "platelet":Double(plateletTextField.text!)!,
            "note":notesTextField.text!,
            "reason":pickerData[reasonPickerView.selectedRowInComponent(0)],
            "anc":Double(ancTextField.text!)!
        ]
        BCClient.sharedInstance.addBcount(info){ data, errorString in
            if let error = errorString  {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    BCClient.alertDialog(self, errorTitle: "Failed inserting the blood count", action: "Ok",errorMsg: "\(error)")
                })
                
            }
            else {
                self.sharedContext.performBlockAndWait(
                    {
                        let count = BCount(dictionary:(data as? [String: AnyObject])!,context: self.sharedContext)
                        count.userInfo = BCClient.sharedInstance.userInfo
                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                )
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            
        }
    }
    
    func updateBcountData(){
        
        var info: [String: AnyObject]
        
        info = ["createdDate": BCClient.sharedDateFormatter.stringFromDate(selectedDate) as String,
            "wbc": Double(wbcTextField.text!)!,
            "hgb":Double(hgbTextField.text!)!,
            "rbc":Double(rbcTextField.text!)!,
            "platelet":Double(plateletTextField.text!)!,
            "anc":Double(ancTextField.text!)!,
            "note":notesTextField.text!,
            "reason":pickerData[reasonPickerView.selectedRowInComponent(0)],
            "userName":BCClient.sharedInstance.userId
        ]
        
        BCClient.sharedInstance.updateBcount(self.bcount.id!, count: info){ result, errorString in
            if let error = errorString  {
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    BCClient.alertDialog(self, errorTitle: "Failed updating the blood count", action: "Ok",errorMsg: "\(error)")
                })
                
            }
            else {
                self.sharedContext.performBlockAndWait({
                    self.bcount.createdDate = self.selectedDate!
                    self.bcount.wbc = Double(self.wbcTextField.text!)!
                    self.bcount.hgb = Double(self.hgbTextField.text!)!
                    self.bcount.rbc = Double(self.rbcTextField.text!)!
                    self.bcount.platelet = Double(self.plateletTextField.text!)!
                    self.bcount.anc = Double(self.ancTextField.text!)!
                    
                    CoreDataStackManager.sharedInstance().saveContext()
                })
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.navigationController?.popViewControllerAnimated(true)
                })
            }
            
        }
        
    }
    // MARK: - Core Data Convenience
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String) -> Bool {
            
            let inverseSet = NSCharacterSet(charactersInString:"0123456789.").invertedSet
            
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            
            let filtered = components.joinWithSeparator("")
            
            return string == filtered
            
    }
    
    var toolBar:UIToolbar{
        
        let toolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.size.width, 40.0))
        
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        toolBar.barStyle = UIBarStyle.BlackTranslucent
        
        toolBar.tintColor = UIColor.whiteColor()
        
        toolBar.backgroundColor = UIColor.blackColor()
        
        
        let todayBtn = UIBarButtonItem(title: "Today", style: UIBarButtonItemStyle.Plain, target: self, action: "tappedTodayToolBarBtn:")
        
        let okBarBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "donePressed:")
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width / 3, height: self.view.frame.size.height))
        
        label.font = UIFont(name: "Helvetica", size: 12)
        
        label.backgroundColor = UIColor.clearColor()
        
        label.textColor = UIColor.whiteColor()
        
        label.text = "Select a due date"
        
        label.textAlignment = NSTextAlignment.Center
        
        let textBtn = UIBarButtonItem(customView: label)
        
        toolBar.setItems([todayBtn,flexSpace,textBtn,flexSpace,okBarBtn], animated: true)
        return toolBar
    }
    
    func donePressed(sender: UIBarButtonItem) {
        
        dateTextField.resignFirstResponder()
        
    }
    
    func tappedTodayToolBarBtn(sender: UIBarButtonItem) {
        
        let dateformatter = NSDateFormatter()
        
        dateformatter.dateStyle = NSDateFormatterStyle.MediumStyle
        
        dateformatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        dateTextField.text = dateformatter.stringFromDate(NSDate())
        
        dateTextField.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
}
