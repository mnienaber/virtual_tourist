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

    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var image: Data?
    @NSManaged public var pin: Pin?

}
