//
//  Client.swift
//  itunes_lookup
//
//  Created by Michael Nienaber on 8/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit

class Client : NSObject {

  let session = URLSession.shared
  var appDelegate: AppDelegate!


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
}

extension Client {

  class func sharedInstance() -> Client {
    struct Singleton {
      static var sharedInstance = Client()
    }
    return Singleton.sharedInstance
  }


}
//
//extension UIImageView {
//
//    func downloadImageFrom(link:String, contentMode: UIViewContentMode) {
//        URLSession.shared.dataTask( with: URL(string:link)!, completionHandler: {
//            (data, response, error) -> Void in
//            DispatchQueue.main.async {
//                self.contentMode =  contentMode
//                if let data = data { self.image = UIImage(data: data) }
//            }
//        }).resume()
//    }
//}
