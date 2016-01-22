//
//  BCConvenience.swift
//  BCount
//
//  Created by Vikas Varma on 1/7/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
import UIKit
extension BCClient{
    
    static func alertDialog(viewController:UIViewController, errorTitle: String, action: String, errorMsg:String) -> Void{
        
        let alertController = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(alertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    static func alertDialogWithHandler(viewController: UIViewController, errorTitle: String, action:String, errorMsg: String, handler: UIAlertAction! -> Void) {
        
        let alertController = UIAlertController(title: errorTitle, message: errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: action, style: UIAlertActionStyle.Cancel, handler: handler)
        alertController.addAction(alertAction)
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alertController, animated: true, completion: nil)
        })
    }
    
    func doBCountLogin(email: String!, password: String!, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters: [String : AnyObject] = [
                Parameters.grantType:"password",
                Parameters.username:email,
                Parameters.password:password
            ]
            let body = [String : AnyObject] ()
            let apiLoginString = "\(Constants.api_key):\(Constants.secret_key)"
            let apiLoginData = apiLoginString.dataUsingEncoding(NSUTF8StringEncoding)!
            let base64ApiLoginString = apiLoginData.base64EncodedStringWithOptions([])
            
            //print(base64ApiLoginString)
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Basic \(base64ApiLoginString)"
            ]
            taskForPOSTMethod(BCClient.Constants.baseSecuredBCountURL+BCClient.Methods.login_method, parameters: parameters,headers:headers, jsonBody: body ) { JSONResult, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if  error != nil {
                    
                    completionHandler(success: false, errorString: error?.localizedFailureReason!)
                } else {
                    
                    let userdata = (JSONResult as! NSData)
                    BCClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        //If we failed to parse the data return the reason why
                        if parseError != nil{
                            
                            completionHandler(success: false, errorString: parseError?.localizedDescription)
                        }else{
                            if let _ = JSONData["access_token"] as? String  {
                                //print(JSONData)
                                //Save the access_token for future use
                                self.access_token = JSONData["access_token"] as? String
                                
                                self.getBCCountUserInfo(){ (result, errorString) in
                                    
                                    if errorString != nil{
                                        completionHandler(success: false, errorString: parseError?.localizedDescription)
                                    }else{
                                        //successfully got the userInfo
                                        completionHandler(success: true, errorString: nil)
                                    }
                                }
                                
                            }else{
                                
                                //Failed to get the userID, so return a generic error
                                completionHandler(success: false, errorString: "Unable to obtain access_token. Please re-try login.")
                            }
                        }
                        
                    }
                    
                }
                
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
        
    }
    
    func getBCCountUserInfo(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters = [String : AnyObject] ()
            
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Bearer \(self.access_token)"
            ]
            _ = taskForGETMethod(Constants.baseSecuredBCountURL + BCClient.Methods.getUserInfo, parameters: parameters,headers:headers) { data, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(success: false, errorString: error!.localizedFailureReason!)
                }
                else{
                    //subset the data and save the id after checking for errors
                    let userdata = data as! NSData
                    BCClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        
                        print("JSON User Data: \(JSONData)")
                        
                        if parseError != nil{
                            
                            completionHandler(success: false, errorString: parseError!.localizedDescription)
                        }else{
                            
                            if let userId = JSONData["id"] as? String{
                                
                                self.userId = userId
                                self.userMapObj = JSONData as? [String:AnyObject]
                                completionHandler(success :true,  errorString: nil)
                            }
                        }
                    }
                }
                
            }
        }else{
            
            completionHandler(success: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    
    func getBCountList(completionHandler: (result: AnyObject!, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters = [String : AnyObject] ()
            
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Bearer \(self.access_token)"
            ]
            _ = taskForGETMethod(Constants.baseSecuredBCountURL + BCClient.Methods.getBCounts, parameters: parameters,headers:headers) { data, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(result: nil, errorString: error!.localizedFailureReason!)
                }
                else{
                    //subset the data and save the id after checking for errors
                    let userdata = data as! NSData
                    BCClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        
                        print("JSON User Data: \(JSONData)")
                        
                        if parseError != nil{
                            
                            completionHandler(result: nil, errorString: parseError!.localizedDescription)
                        }else{
                            
                            
                            completionHandler(result :JSONData,  errorString: nil)
                        }
                    }
                }
            }
        }else{
            
            completionHandler(result: nil, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    func deleteBcount(bcountId:String!, completionHandler: (result: Bool!, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters = [String : AnyObject] ()
            
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Bearer \(self.access_token)"
            ]
            _ = taskForDELETEMethod(Constants.baseSecuredBCountURL + BCClient.Methods.bCount+"\(bcountId)", parameters: parameters,headers:headers) { data, error in
                print(Constants.baseSecuredBCountURL + BCClient.Methods.bCount+"\(bcountId)")
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(result: false, errorString: error!.localizedFailureReason!)
                }
                else{
                    completionHandler(result: true, errorString:nil)
                    
                }
            }
        }else{
            
            completionHandler(result: false, errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    func addBcount(count: AnyObject, completionHandler: (result:AnyObject?, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters = [String : AnyObject] ()
            
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Bearer \(self.access_token)"
            ]
            
            let jsonBody = count as! [String: AnyObject]
                       
            _ = taskForPOSTMethod(Constants.baseSecuredBCountURL + BCClient.Methods.bCount, parameters: parameters,headers:headers,jsonBody: jsonBody) { data, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(result: nil, errorString: error!.localizedFailureReason!)
                }
                else{
                    let userdata = data as! NSData
                    BCClient.parseJSONWithCompletionHandler(userdata) { (JSONData, parseError) in
                        
                        print("JSON User Data: \(JSONData)")
                        
                        if parseError != nil{
                            
                            completionHandler(result:  JSONData, errorString: parseError!.localizedDescription)
                        }else{
                            
                            
                            completionHandler(result :JSONData,  errorString: nil)
                        }
                    }
                }
            }
        }else{
            
            completionHandler(result: nil,errorString: "Unable to connect to Internet!.")
            
        }
    }
    
    func updateBcount(id:String,count: AnyObject, completionHandler: (result: Bool!, errorString: String?) -> Void) {
        
        if IJReachability.isConnectedToNetwork(){
            
            let parameters = [String : AnyObject] ()
            
            let headers : [String: String] = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization":"Bearer \(self.access_token)"
            ]
            
            let jsonBody = count as! [String: AnyObject]
            
            _ = taskForPUTMethod(Constants.baseSecuredBCountURL + BCClient.Methods.bCount+id, parameters: parameters,headers:headers,jsonBody: jsonBody) { data, error in
                
                /* 3. Send the desired value(s) to completion handler */
                if error != nil {
                    
                    completionHandler(result: false, errorString: error!.localizedFailureReason!)
                }
                else{
                    completionHandler(result: true, errorString:nil)
                    
                }
            }
        }else{
            
            completionHandler(result: false, errorString: "Unable to connect to Internet!.")
            
        }
    }


    
    func formatError(error: String) -> String{
        
        if error.rangeOfString(":") != nil{
            
            var errArray = error.componentsSeparatedByString(":")
            return errArray[1] as String
        }else{
            
            return error
        }
    }
}
