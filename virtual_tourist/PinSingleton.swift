//
//  StudentSingleton.swift
//  On The Map
//
//  Created by Michael Nienaber on 8/10/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation


class PinSingleton: NSObject {

  var pinCollection = [Pin]()

  class func sharedInstance() -> Pin {
    struct Singleton {
      static var sharedInstance = Pin()
    }
    return Singleton.sharedInstance
  }
}
