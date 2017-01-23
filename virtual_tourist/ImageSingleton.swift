//
//  ImageSingleton.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//
import UIKit
import Foundation

class ImageSingleton: UIViewController {

  var image = [ImageObject]()

  class func sharedInstance() -> ImageSingleton {
    struct Singleton {
      static var sharedInstance = ImageSingleton()
    }
    return Singleton.sharedInstance
  }
}
