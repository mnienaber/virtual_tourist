//
//  Convenience.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit

extension Client {

  func getImages(latitude: Double, longitude: Double, completionHanderForGetImages: @escaping (_ results: [ImageObject]?, _ error: NSError) -> Void) {

    let lat:String = String(format:"%f", latitude)
    let lon:String = String(format:"%f", longitude)

    let methodArguments: [String: String?] = [
      "method": Client.Constants.Scheme.METHOD_NAME,
      "api_key": Client.Constants.Scheme.API_KEY,
      "lat": lat,
      "lon": lon,
      "extras": Client.Constants.Scheme.EXTRAS,
      "format": Client.Constants.Scheme.DATA_FORMAT,
      "nojsoncallback": Client.Constants.Scheme.NO_JSON_CALLBACK,
      "per_page": Client.Constants.Scheme.PER_PAGE
    ]

    _ = URLSession.shared
    let urlString = Client.Constants.Scheme.BASE_URL + escapedParameters(parameters: methodArguments as [String : AnyObject])
    let url = NSURL(string: urlString)!
    let request = NSURLRequest(url: url as URL)

    taskForGETMethod(request: request) { results, error in

      print("are there results?????")

      if let error = error {

        completionHanderForGetImages(nil, error)
      } else {

        if let results = results?[Client.Constants.JSONResponseKeys.FlickrResults] as? [String:AnyObject] {

          let test = results["photo"]
          let url = test?["url_m"]
          print("test: \(test)")
          print("test: \(url)")

          let images = ImageObject.SLOFromResults(results: test as! [[String : AnyObject]])
          print("images:  \(images)")
          //ImageSingleton.sharedInstance().image = images
          print(images)
          //completionHanderForGetImages(images, nil)

        }
      }
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
}

