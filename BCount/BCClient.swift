//
//  BCClient.swift
//  BCount
//
//  Created by Vikas Varma on 1/7/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
class BCClient {
    
    
    var session: NSURLSession
    
    var access_token:String!
    var userId: String!
    var userMapObj: [String: AnyObject]!
    var userInfo: UserInfo!
    var bcount: BCount!
    
    var config = UserConfig.unarchivedInstance() ?? UserConfig()
    
    init() {
        session = NSURLSession.sharedSession()
    }
    
    static let sharedInstance = BCClient()
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            //println(parsedResult)
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    //Implement GET Method
    func taskForGETMethod(urlString: String, parameters: [String : AnyObject],headers:[String:String],completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let urlString = urlString + BCClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        if !headers.isEmpty {
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        //println(request)
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let _ = downloadError {
                completionHandler(result:nil,  error:downloadError)
            } else {
                completionHandler(result: data,  error:nil)
            }
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPUTMethod(urlString: String, parameters: [String : AnyObject], headers:[String:String], jsonBody: AnyObject, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + BCClient.escapedParameters(mutableParameters))!
        
        let request = NSMutableURLRequest(URL: url)
        let body: NSData?
        do {
            body = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch _ as NSError {
            // jsonifyError = error
            body = nil
        }

        request.HTTPMethod = "PUT"
        
        if !headers.isEmpty{
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        print(body)
        request.HTTPBody = body
        
        print(request)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let _ = downloadError {
                
                completionHandler(result: nil, error: downloadError)
            } else {
                
                completionHandler(result:data, error:nil)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForDELETEMethod(urlString: String, parameters: [String : AnyObject], headers:[String:String], completionHandler: (result: Bool!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + BCClient.escapedParameters(mutableParameters))!
        
        let request = NSMutableURLRequest(URL: url)
        //var jsonifyError: NSError? = nil
        request.HTTPMethod = "DELETE"
        
        if !headers.isEmpty{
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
       
        //print(request)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let _ = downloadError {
                
                completionHandler(result: false, error: downloadError)
            } else {
                
                completionHandler(result:true, error:nil)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(urlString: String, parameters: [String : AnyObject], headers:[String:String], jsonBody: AnyObject, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* 1. Set the parameters */
        let mutableParameters = parameters
        
        /* 2/3. Build the URL and configure the request */
        let url = NSURL(string: urlString + BCClient.escapedParameters(mutableParameters))!
        
        let request = NSMutableURLRequest(URL: url)
        //var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        
        if !headers.isEmpty{
            for (key,value) in headers{
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        let body: NSData?
        do {
            body = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch _ as NSError {
            // jsonifyError = error
            body = nil
        }

        print(jsonBody)
        request.HTTPBody = body 
        
        //println(request)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            if let _ = downloadError {
                
                completionHandler(result: nil, error: downloadError)
            } else {
                
                completionHandler(result:data, error:nil)
            }
        }
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    func downloadImage(imagePath: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: imagePath)!
        
        //print("imageUrl \(url)")
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                let newError = BCClient.errorForData(data, response: response, error: error)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from BCClient. If we cant then return the previous error
    
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], errorMessage = parsedResult["message"] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "BC Client Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
        
    }
    
    class var sharedDateFormatter: NSDateFormatter  {
        
        struct Singleton {
            static let dateFormatter = Singleton.generateDateFormatter()
            
            static func generateDateFormatter() -> NSDateFormatter {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"                
                return formatter
            }
        }
        
        return Singleton.dateFormatter
    }
    
    class var sharedNumberFormatter : NSNumberFormatter {
        
        struct Singleton {
            static let numberFormatter = Singleton.generateNumberFormatter()
                
            static func generateNumberFormatter() -> NSNumberFormatter {
                let numberFormatter = NSNumberFormatter()
                numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
                return numberFormatter
            }
        }
        return Singleton.numberFormatter
    }
}
