//
//  Photos+CoreDataClass.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 11/28/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import CoreData

class Photos: NSManagedObject {

  convenience init(title: String, url: String, context: NSManagedObjectContext) {

    // An EntityDescription is an object that has access to all
    // the information you provided in the Entity part of the model
    // you need it to create an instance of this class.
    if let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
      self.init(entity: ent, insertInto: context)
//      self.image = image
      self.title = title
      self.url = url
    } else {
      fatalError("Unable to find Entity name!")
    }
  }

}
