//
//  Pin+CoreDataClass.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 11/28/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {

  convenience init(latitude: Float, longitude: Float, locationName: String, context: NSManagedObjectContext) {

    // An EntityDescription is an object that has access to all
    // the information you provided in the Entity part of the model
    // you need it to create an instance of this class.
    if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
      self.init(entity: ent, insertInto: context)
      self.latitude = latitude
      self.longitude = longitude
      self.locationName = locationName
    } else {
      fatalError("Unable to find Entity name!")
    }
  }

}
