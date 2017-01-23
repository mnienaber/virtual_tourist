//
//  Client.swift
//  itunes_lookup
//
//  Created by Michael Nienaber on 8/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Client : NSObject {

  let session = URLSession.shared
  var appDelegate: AppDelegate!
  var photoManagedObject = [NSManagedObject]()


  override init() {
    super.init()
  }

  func taskForGETMethod(request: NSURLRequest, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {

    let task = session.dataTask(with: request as URLRequest) { data, response, error in

      func sendError(_ error: String) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
      }

      guard (error == nil) else {
        sendError("There was an error with your request: \(error)")
        return
      }

      guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
        sendError("Your request returned a status code other than 2xx!")
        return
      }

      guard let data = data else {
        sendError("No data was returned by the request!")
        return
      }
      print(data)

      self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
    }
    task.resume()
    return task

  }

  func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {

    var parsedResult: Any!
    do {
      parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
      print("this is the parsed result: \(parsedResult)")
    } catch {
      let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
      completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }

    completionHandlerForConvertData(parsedResult as AnyObject?, nil)
    
  }

//  func saveToCoreData(title: String, url: String) {
//    //1
//    let appDelegate =
//      UIApplication.shared.delegate as! AppDelegate
//
//    let managedContext = appDelegate.managedObjectContext
//
//    //2
//    let entity =  NSEntityDescription.entity(forEntityName: "Person",
//                                             in:managedContext)
//
//    let person = NSManagedObject(entity: entity!,
//                                 insertInto: managedContext)
//
//    //3
//    person.setValue(title, forKey: "title")
//
//    //4
//    do {
//      try managedContext.save()
//      //5
//      photoManagedObject.append(person)
//    } catch let error as NSError  {
//      print("Could not save \(error), \(error.userInfo)")
//    }
//  }
}

extension Client {

  class func sharedInstance() -> Client {
    struct Singleton {
      static var sharedInstance = Client()
    }
    return Singleton.sharedInstance
  }


}

