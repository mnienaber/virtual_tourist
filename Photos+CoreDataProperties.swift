//
//  Photos+CoreDataProperties.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 11/28/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import CoreData


extension Photos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photos> {
        return NSFetchRequest<Photos>(entityName: "Photos");
    }

    @NSManaged public var image: NSData?
    @NSManaged public var pin: Pin?

}
