//
//  UserInfo.swift
//  BCount
//
//  Created by Vikas Varma on 1/14/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

import Foundation
import CoreData

class UserInfo:NSManagedObject {
    
    struct Keys {
        static let id = "id"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let name    = "name"
        static let emailAddress    = "emailAddress"
    }
    
    @NSManaged var id: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var name: String?
    @NSManaged var emailAddress: String?
    @NSManaged var counts: [BCount]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("UserInfo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = dictionary[Keys.id] as? String
        self.firstName = dictionary[Keys.firstName] as? String
        self.lastName = dictionary[Keys.lastName] as? String
        self.name = dictionary[Keys.name] as? String
        self.emailAddress = dictionary[Keys.emailAddress] as? String
    }
    
}