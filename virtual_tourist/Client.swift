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
  var latitude = Float()
  var longitude = Float()
//  var photosArray: [ImageObject]


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
        sendError("There was an error with your request: \(String(describing: error))")
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
      self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
    }
    task.resume()
    return task
  }

  func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {

    var parsedResult: [String:AnyObject]!
    do {
      parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
    } catch {
      let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
      completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }

    if let photosDictionary = parsedResult[Client.Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] {

      guard let photosArray = photosDictionary[Client.Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
        completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: nil))
        return
      }

      ImageObject.SLOFromResults(photosArray) { (finishedConverting, pictures) in

        if finishedConverting {

          ImageObjectDetail.sharedInstance().pictures = pictures
          for pic in ImageObjectDetail.sharedInstance().pictures {

            Photos.corePhotoWithNetworkInfo(pictureInfo: pic, pinUsed: <#T##Pin#>, inManagedObjectContext:
          }

          print("pictures: \(pictures)")
          completionHandlerForConvertData(parsedResult as AnyObject, nil)
        }

    completionHandlerForConvertData(parsedResult as AnyObject?, nil)
      }
    }
  }

}

extension Client {

  class func sharedInstance() -> Client {
    struct Singleton {
      static var sharedInstance = Client()
    }
    return Singleton.sharedInstance
  }
}

