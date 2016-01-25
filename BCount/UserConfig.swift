//
//  UserConfig.swift
//  BCount
//
//  Created by Vikas Varma on 1/24/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation

// MARK: - Files Support
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("BCount-Context")


class UserConfig: NSObject, NSCoding {
    
    var max_per_page = 200
    var dateUpdated: NSDate? = nil
    
    override init() {
        
    }
    
    convenience init?(dictionary: [String : AnyObject]) {
        
        self.init()
        
        if let max_per_page = dictionary["max_per_page"] as? Int {
            self.max_per_page = max_per_page
        }
        dateUpdated = NSDate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        max_per_page = aDecoder.decodeObjectForKey("max_per_page") as! Int
        dateUpdated = aDecoder.decodeObjectForKey("date_update_key") as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(max_per_page, forKey: "max_per_page")
        aCoder.encodeObject(dateUpdated, forKey: "date_update_key")
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> UserConfig? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? UserConfig
        } else {
            return nil
        }
    }
}

