//
//  SettingsPageSettingsViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/24/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import UIKit

class SettingsPageSettingsViewController: UIViewController {
    
    @IBOutlet weak var maxPagesTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        maxPagesTextField.text = "\(BCClient.sharedInstance.config.max_per_page)"
    }
    
    @IBAction func updateSettings(sender: UIButton) {
        
        BCClient.sharedInstance.config.max_per_page = NSString(string: maxPagesTextField.text!).integerValue
        
        BCClient.sharedInstance.config.save()
        
        
    }
}
