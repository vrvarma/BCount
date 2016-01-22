//
//  BCount.swift
//  BCount
//
//  Created by Vikas Varma on 1/14/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
import CoreData

class BCount:NSManagedObject {
    
    struct Keys {
        static let id = "id"
        static let createdDate = "createdDate"
        static let userName = "userName"
        static let wbc    = "wbc"
        static let hgb    = "hgb"
        static let rbc    = "rbc"
        static let platelet = "platelet"
        static let anc = "anc"
    }
    
    @NSManaged var id: String?
    @NSManaged var createdDate: NSDate?
    @NSManaged var userName: String?
    @NSManaged var wbc: NSNumber?
    @NSManaged var hgb: NSNumber?
    @NSManaged var rbc: NSNumber?
    @NSManaged var platelet: NSNumber?
    @NSManaged var anc: NSNumber?
    @NSManaged var userInfo: UserInfo?
    @NSManaged var visitInfo:VisitInfo?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("BCount", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = dictionary[Keys.id] as? String
        self.userName = dictionary[Keys.userName] as? String
        self.wbc = dictionary[Keys.wbc] as? Double
        self.hgb = dictionary[Keys.hgb] as? Double
        self.rbc = dictionary[Keys.rbc] as? Double
        self.platelet = dictionary[Keys.platelet] as? Double
        self.anc = dictionary[Keys.anc] as? Double
        if let dateString = dictionary[Keys.createdDate] as? String {
            
            if let date = BCClient.sharedDateFormatter.dateFromString(dateString) {
                self.createdDate = date
                print(self.createdDate)
            }
        }
        self.visitInfo = VisitInfo(dictionary: dictionary, context: context)
        self.visitInfo?.count = self
    }
    
    func generateString() -> String{
        
        return "WBC: \(wbc!), HGB: \(hgb!), RBC: \(rbc!), Platelet: \(platelet!), ANC: \(anc!)"
    }
    func generateDateString() -> String{
        
        return NSDateFormatter.localizedStringFromDate(createdDate!,
            dateStyle: .MediumStyle,
            timeStyle: .MediumStyle)
    }
}
