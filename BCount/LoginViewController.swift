//
//  LoginViewController.swift
//  BCount
//
//  Created by Vikas Varma on 1/7/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController, UITextFieldDelegate,NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var session: NSURLSession!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        session = NSURLSession.sharedSession()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        //Hide the nav bar on the login view
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        //Make the email field the responder
        emailTextField.becomeFirstResponder()
        
        // Subscribe to keyboard notifications to allow the view to raise when necessary
        subscribeToKeyboardNotifications()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //TextField delegate methods
    func textFieldShouldReturn(textField:UITextField)->Bool{
        
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func loginPressed(sender: UIButton) {
        
        BCClient.sharedInstance.doBCountLogin(emailTextField.text, password:passwordTextField.text){ (success, errorString) in
            if success {
                
                self.completeLogin()
                
            } else {
                dispatch_async(dispatch_get_main_queue()){
                    
                    BCClient.alertDialog(self, errorTitle: "Login Failed", action: "OK", errorMsg: errorString!)
                }
            }
        }
    }
    
    
    //Subscribe to keyboard notifications.
    func subscribeToKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification,
            object: nil)
        
    }
    
    //Unsubscribe from keyboard notifications
    //called when the controller exits.
    func unsubscribeFromKeyboardNotifications() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
        
    }
    
    //Keyboard functions.
    //slide the picture up, to show the keyboard
    func keyboardWillShow(notification: NSNotification) {
        
        if passwordTextField.isFirstResponder() {
            
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //slide back the keyboard, when the user is done editing
    func keyboardWillDisappear(notification: NSNotification){
        
        if passwordTextField.isFirstResponder() {
            
            view.frame.origin.y = 0
        }
    }
    
    //method to calculates the keyboard height
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func completeLogin() {
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {}
        
        var user: UserInfo!
        
        let userList = self.fetchedResultsController.fetchedObjects as! [UserInfo]
    
        if userList.count == 0{
            self.sharedContext.performBlockAndWait({
                
                user = UserInfo(dictionary: BCClient.sharedInstance.userMapObj!,context: self.sharedContext)
                BCClient.sharedInstance.userInfo = user
            })
        }else{
            //Update the cached data
            
            let userList = self.fetchedResultsController.fetchedObjects as! [UserInfo]
            user = userList[0]
            self.sharedContext.performBlockAndWait({
                
                let userInfo = BCClient.sharedInstance.userMapObj!
                user.name = userInfo["name"] as? String
                user.firstName = userInfo["firstName"] as? String
                user.lastName = userInfo["lastName"] as? String
                user.emailAddress = userInfo["emailAddress"] as? String
                
                //Keeping the userInfo cached.
                BCClient.sharedInstance.userInfo = user
                CoreDataStackManager.sharedInstance().saveContext()
            })
        }
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        })
        
        
        
    }
    
    
    @IBAction func openBCountSignup(sender: UIButton) {
        
         UIApplication.sharedApplication().openURL(NSURL(string: BCClient.Constants.BCountSignUpURL)!)
    }
    
    // MARK: - Core Data Convenience
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "UserInfo")
        
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = NSPredicate(format: "id == %@", BCClient.sharedInstance.userId);
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
        
    }()
}

