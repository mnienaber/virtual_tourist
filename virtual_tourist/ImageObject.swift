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

  let farm: AnyObject
  let height: AnyObject
  let id: AnyObject
  let isFamiliy: AnyObject
  let isFriend: AnyObject
  let isPublic: AnyObject
  let owner: AnyObject
  let secret: AnyObject
  let server: AnyObject
  let title: AnyObject
  let imageUrl: AnyObject
  let width: AnyObject


  init?(dictionary: [String:AnyObject]) {

    guard let f = (dictionary[Client.Constants.ParseResponseKeys.Farm] as AnyObject!) else { return nil }
    farm = f
    guard let h = (dictionary[Client.Constants.ParseResponseKeys.Height] as AnyObject!) else { return nil }
    height = h
    guard let i = (dictionary[Client.Constants.ParseResponseKeys.Id] as AnyObject!) else { return nil }
    id = i
    guard let ifa = (dictionary[Client.Constants.ParseResponseKeys.IsFamily] as AnyObject!) else { return nil }
    isFamiliy = ifa
    guard let ifr = (dictionary[Client.Constants.ParseResponseKeys.IsFriend] as AnyObject!) else { return nil }
    isFriend = ifr
    guard let ip = (dictionary[Client.Constants.ParseResponseKeys.IsPubic] as AnyObject!) else { return nil }
    isPublic = ip
    guard let o = (dictionary[Client.Constants.ParseResponseKeys.Owner] as AnyObject!) else { return nil }
    owner = o
    guard let s = (dictionary[Client.Constants.ParseResponseKeys.Secret] as AnyObject!) else { return nil }
    secret = s
    guard let ser = (dictionary[Client.Constants.ParseResponseKeys.Server] as AnyObject!) else { return nil }
    server = ser
    guard let t = (dictionary[Client.Constants.ParseResponseKeys.Title] as AnyObject!) else { return nil }
    title = t
    guard let iurl = (dictionary[Client.Constants.ParseResponseKeys.ImageUrl] as AnyObject!) else { return nil }
    imageUrl = iurl
    guard let w = (dictionary[Client.Constants.ParseResponseKeys.Width] as AnyObject!) else { return nil }
    width = w
  }

  static func SLOFromResults(results: [String:AnyObject]) -> Bool {

    func displayError(_ error: String) {
      print(error)
    }

    guard let photoArray = results[Client.Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
        displayError("Cannot find keys '\(Client.Constants.FlickrResponseKeys.Photos)' and '\(Client.Constants.FlickrResponseKeys.Photo)' in \(results)")
        return false
    }
//
//    let firstPhoto = photoArray.first
//
//    let photoTitle = firstPhoto?[Client.Constants.FlickrResponseKeys.Title] as? String

//    guard let imageUrlString = photoArray[Client.Constants.FlickrResponseKeys.MediumURL] as? String else {
//      displayError("Cannot find key '\(Client.Constants.FlickrResponseKeys.MediumURL)' in \(photoArray)")
//      return false
//    }



    print("photoArray: \(photoArray)")
    for result in photoArray {

      print("this is a result: \(result["title"]))")
      print("photoTitle: \(result["url_m"])")

    }
    return true
  }
}

