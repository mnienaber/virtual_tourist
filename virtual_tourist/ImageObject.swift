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
  let owner: String
  let secret: String
  let server: AnyObject
  let title: String
  let imageUrl: String
  let width: AnyObject


  init?(dictionary: [String:AnyObject]) {

    guard let f = dictionary[Client.Constants.ParseResponseKeys.Farm] as AnyObject? else { return nil }
    farm = f
    guard let h = dictionary[Client.Constants.ParseResponseKeys.Height] as AnyObject? else { return nil }
    height = h
    guard let i = dictionary[Client.Constants.ParseResponseKeys.Id] as AnyObject? else { return nil }
    id = i
    guard let ifa = dictionary[Client.Constants.ParseResponseKeys.IsFamily] as AnyObject? else { return nil }
    isFamiliy = ifa
    guard let ifr = dictionary[Client.Constants.ParseResponseKeys.IsFriend] as AnyObject? else { return nil }
    isFriend = ifr
    guard let ip = dictionary[Client.Constants.ParseResponseKeys.IsPubic] as AnyObject? else { return nil }
    isPublic = ip
    guard let o = dictionary[Client.Constants.ParseResponseKeys.Owner] as? String else { return nil }
    owner = o
    guard let s = dictionary[Client.Constants.ParseResponseKeys.Secret] as? String else { return nil }
    secret = s
    guard let ser = dictionary[Client.Constants.ParseResponseKeys.Server] as AnyObject? else { return nil }
    server = ser
    guard let t = dictionary[Client.Constants.ParseResponseKeys.Title] as? String else { return nil }
    title = t
    guard let iurl = dictionary[Client.Constants.ParseResponseKeys.ImageUrl] as? String else { return nil }
    imageUrl = iurl
    guard let w = dictionary[Client.Constants.ParseResponseKeys.Width] as AnyObject? else { return nil }
    width = w
  }

  static func SLOFromResults(results: [[String:AnyObject]]) -> [ImageObject] {

    var photosArray = [ImageObject]()

    for result in results {

//      print("slo result: \(result)")
      let url = result["url_m"]
      print(url!)

      let title = result["title"]
      print(title!)
      photosArray.append(result)
//      if let object = ImageObject(dictionary: result) {
//
//        print("img: \(object)")
//
//        ImageSingleton.sharedInstance().image.append(object)
//        print("imgob result: \(ImageSingleton.sharedInstance().image)")
      }
    }
    //print(ImageSingleton.sharedInstance().image)
    return ImageSingleton.sharedInstance().image
  }
}
