//
//  Convenience.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension Client {

  typealias CompletionHandler = (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void


  func getImages(pin: Pin, completionHanderForGetImages: @escaping (_ results: Bool, _ error: Error?) -> Void) {

    print("2")

    let lat:String = String(format:"%f", pin.latitude)
    let lon:String = String(format:"%f", pin.longitude)


    let methodArguments: [String: AnyObject?] = [
      "method": Client.Constants.Scheme.METHOD_NAME as AnyObject,
      "api_key": Client.Constants.Scheme.API_KEY as AnyObject,
      "lat": lat as AnyObject,
      "lon": lon as AnyObject,
      "extras": Client.Constants.Scheme.EXTRAS as AnyObject,
      "format": Client.Constants.Scheme.DATA_FORMAT as AnyObject,
      "nojsoncallback": Client.Constants.Scheme.NO_JSON_CALLBACK as AnyObject,
      "per_page": Client.Constants.Scheme.PER_PAGE as AnyObject
    ]


    _ = URLSession.shared
    let urlString = Client.Constants.Scheme.BASE_URL + escapedParameters(parameters: methodArguments as [String : AnyObject])
    let url = NSURL(string: urlString)!
    let request = NSURLRequest(url: url as URL)

    taskForGETMethod(request: request, methodArguments: methodArguments as [String : AnyObject]) { results, error in

      if let error = error {

        completionHanderForGetImages(false, error)
      } else {
        completionHanderForGetImages(true, nil)
          }
        }
  }


  func savePinToCoreData(lat: Float, long: Float) -> Void {

    let appDelegate =
      UIApplication.shared.delegate as! AppDelegate
    let managedContext = appDelegate.stack.context
    let entity =  NSEntityDescription.entity(forEntityName: "Pin",
                                             in:managedContext)
    let pin = NSManagedObject(entity: entity!,
                                insertInto: managedContext)
    pin.setValue(lat, forKey: "latitude")
    pin.setValue(long, forKey: "longitude")

    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save pin \(error), \(error.userInfo)")
    }
  }

  func escapedParameters(parameters: [String : AnyObject]) -> String {

    var urlVars = [String]()

    for (key, value) in parameters {

      let stringValue = "\(value)"
      let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
      urlVars += [key + "=" + "\(escapedValue!)"]
    }
    return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
  }

  func getImageData(_ url: String, completionHandlerForImage: @escaping (_ data: Data?, _ error: NSError?) -> Void) -> URLSessionTask {

    let url = URL(string: url)!
    let request = URLRequest(url: url)

    let task = self.session.dataTask(with: request) { (data, response, error) in

      func sendError(_ error: String) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandlerForImage(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
      }

      guard (error == nil) else {
        sendError("There was an error with your request: \(error)")
        return
      }

      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        sendError("Your request returned a status code other than 2xx!")
        return
      }

      guard let data = data else {
        sendError("No data was returned by the request!")
        return
      }

      print("Download completed: \(completionHandlerForImage)")
      completionHandlerForImage(data, nil)
    }
    task.resume()
    return task
  }
}


