//
//  ImageObjectDetail.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 5/8/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import Foundation


class ImageObjectDetail: NSObject {

  var pictures = [ImageObject]()

  class func sharedInstance() -> ImageObjectDetail {

    struct Singleton {
      static var sharedInstance = ImageObjectDetail()
    }
    return Singleton.sharedInstance
  }
}
