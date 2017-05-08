//
//  Photos+CoreDataClass.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 11/28/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import CoreData

//@objc(Photos)
class Photos: NSManagedObject {

  convenience init(title: String, url: String, image: Data, context: NSManagedObjectContext) {

    // An EntityDescription is an object that has access to all
    // the information you provided in the Entity part of the model
    // you need it to create an instance of this class.
    if let ent = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
      self.init(entity: ent, insertInto: context)
      self.title = title
      self.url = url
      self.image = image
    } else {
      fatalError("Unable to find Entity name!")
    }
  }

  class func corePhotoWithNetworkInfo(pictureInfo: ImageObject, pinUsed: Pin, inManagedObjectContext context: NSManagedObjectContext) -> Photos?{
    //Look and see if we have this photo in the database already.
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    //The Photo.name is the same as the VTPicture.id
    request.predicate = NSPredicate(format: "name = %@", pictureInfo.id as CVarArg)

    //First check if the photo exists in the database. If it does, then return it. If it doesnt, then create a ManagedObject for it.
    if let photo = (try? context.fetch(request))?.first as? Photos {
      return photo
    } else if let photo = NSEntityDescription.insertNewObject(forEntityName: "Photos", into: context) as? Photos {
      photo.url = pictureInfo.URL
      photo.title = pictureInfo.title
      photo.pin = pinUsed
      photo.image = pictureInfo.data as Data?

      return photo
    }

    return nil
  }

}
