//
//  FailAlerts.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 3/15/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit

class FailAlerts: UIViewController {

  func failGenOK(title: String, message: String, alerttitle: String) {

    let failLoginAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    failLoginAlert.addAction(UIAlertAction(title: alerttitle, style: UIAlertActionStyle.default, handler: nil))
    self.present(failLoginAlert, animated: true, completion: nil)

  }
}

extension FailAlerts {

  class func sharedInstance() -> FailAlerts {
    struct Singleton {
      static var sharedInstance = FailAlerts()
    }
    return Singleton.sharedInstance
  }
}
