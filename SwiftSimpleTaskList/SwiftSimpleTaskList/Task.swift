//
//  Task.swift
//  
//
//  Created by Prashant on 04/09/15.
//
//

import Foundation
import CoreData

class Task: NSManagedObject {

    @NSManaged var title: String    // task title
    @NSManaged var color: String    // task color
    @NSManaged var dateAdded: NSDate // added date (used for order by)

}
