//
//  ImageObject.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit

struct ImageObject {

  let imageUrl: String

  init?(dictionary: [String:AnyObject]) {

    guard let object = dictionary[Client.Constants.ParseResponseKeys.ImageUrl] as? String else { return nil }
    imageUrl = object
  }

  static func SLOFromResults(results: [[String:AnyObject]]) -> [ImageObject] {

    for result in results {

      if let imageObject = ImageObject(dictionary: result) {

        ImageSingleton.sharedInstance().image.append(imageObject)
      }
    }
    return ImageSingleton.sharedInstance().image
  }
}
