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

  let title: String
  let URL: String
  let id: String
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

  static func SLOFromResults(_ results: [[String:AnyObject]], completionHandlerForResults: @escaping (_ finishedConverting: Bool, _ pictures: [ImageObject]) -> Void) {
    print("5")
    var pictures = [ImageObject]()

    for result in results {

      pictures.append((ImageObject(dictionary: result))!)
    }
    completionHandlerForResults(true, pictures)
  }
}

