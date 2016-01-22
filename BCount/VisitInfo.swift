//
//  VisitInfo.swift
//  BCount
//
//  Created by Vikas Varma on 1/19/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//

//
//  UserInfo.swift
//  BCount
//
//  Created by Vikas Varma on 1/14/16.
//  Copyright © 2016 Vikas Varma. All rights reserved.
//
//  Persist the information related to the Visit
//

import Foundation
import CoreData

class VisitInfo:NSManagedObject {
    
    struct Keys {
        static let id = "id"
        static let note = "note"
        static let reason = "reason"
    }
    
    @NSManaged var id: String?
    @NSManaged var note: String?
    @NSManaged var reason: String?
    @NSManaged var count: BCount?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entityForName("VisitInfo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.id = dictionary[Keys.id] as? String
        self.note = dictionary[Keys.note] as? String
        self.reason = dictionary[Keys.reason] as? String
    }
    
}
