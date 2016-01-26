//
//  SettingsPageSettingsViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/24/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import UIKit

class SettingsPageSettingsViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var maxPagesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxPagesTextField.text = "\(BCClient.sharedInstance.config.max_per_page)"
        maxPagesTextField.delegate = self
    }
    
    @IBAction func updateSettings(sender: UIButton) {
        
        BCClient.sharedInstance.config.max_per_page = NSString(string: maxPagesTextField.text!).integerValue
        
        BCClient.sharedInstance.config.save()
        
    }
    
    func textField(textField: UITextField,shouldChangeCharactersInRange range: NSRange,replacementString string: String) -> Bool {
        
        var startString = ""
        if textField.text != nil {
            
            startString += textField.text!
        }
        startString += string
        let limitNumber = Int(startString)
        if limitNumber >  2000 {
            
            return false
        }
        else {
            
            return true;
        }
        
    }
}
