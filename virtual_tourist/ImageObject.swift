//
//  ImageObject.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct ImageObject {

  var title: String
  var URL: String
  var id: String
  var data: Data?


  init?(dictionary: [String: AnyObject]){
    if let titleFound = dictionary[Client.Constants.FlickrResponseKeys.Title] as? String {
      title = titleFound
    } else {
      title = ""
    }

    if let URLFound = dictionary[Client.Constants.FlickrResponseKeys.MediumURL] as? String {
      URL = URLFound
    } else {
      URL = ""
    }

    if let idFound = dictionary[Client.Constants.FlickrResponseKeys.id] as? String {
      id = idFound
    } else {
      id = ""
    }
  }

  static func SLOFromResults(results: [String:AnyObject]) -> Bool {

    func displayError(_ error: String) {
      print(error)
    }

    guard let photoArray = results[Client.Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
        displayError("Cannot find keys '\(Client.Constants.FlickrResponseKeys.Photos)' and '\(Client.Constants.FlickrResponseKeys.Photo)' in \(results)")
        return false
    }

    for result in photoArray {

      ImageObjectDetail.sharedInstance().pictures.append((ImageObject(dictionary: result))!)

      print("this is a ImageObject result: \(ImageObjectDetail.sharedInstance().pictures))")
    }
    return true
  }
}

