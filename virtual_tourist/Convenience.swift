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

  func getImages(latitude: Float, longitude: Float, completionHanderForGetImages: @escaping (_ results: Bool, _ error: Error?) -> Void) {

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

      if let error = error {

        completionHanderForGetImages(false, error)
      } else {

        if let results = results?[Client.Constants.JSONResponseKeys.FlickrResults] as? [String:AnyObject] {

          let images = results[Client.Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]

          for result in images! {
            let title = result["title"]
            let url = result["url_m"]

            self.saveImageToCoreData(title: title as! String, url: url as! String) { data, response, error in

              if error != nil {

                print(error!)
                completionHanderForGetImages(false, error)
              } else {

                if let data = data {

                  let appDelegate =
                    UIApplication.shared.delegate as! AppDelegate
                  let managedContext = appDelegate.stack.context
                  let entity =  NSEntityDescription.entity(forEntityName: "Photos",
                                                           in:managedContext)
                  let image = NSManagedObject(entity: entity!,
                                              insertInto: managedContext)

                  image.setValue(data, forKey: "image")
                  image.setValue(title, forKey: "title")
                  image.setValue(url, forKey: "url")
                  image.setValue(Client.sharedInstance().latitude, forKey: "latitude")
                  image.setValue(Client.sharedInstance().longitude, forKey: "longitude")

                  do {
                    try managedContext.save()
                    Client.sharedInstance().photoManagedObject.append(image)
                    print("managedobject: \(Client.sharedInstance().photoManagedObject)")
                  } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                  }
                }
              }
            }
          }
        }
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
    pin.setValue(latitude, forKey: "latitude")
    pin.setValue(longitude, forKey: "longitude")

    do {
      try managedContext.save()
      print("pin managedContext \(Client.sharedInstance().photoManagedObject.append(pin))")
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

  func getDataFromUrl(url: URL, completion: @escaping CompletionHandler) {

    URLSession.shared.dataTask(with: url) {
      (data, response, error) in
      print("Download completed: \(data)")
      completion(data, response, error)
      }.resume()
  }

  func downloadImage(title: String, url: String, completion: @escaping CompletionHandler) {

    let fileUrl = URL(string: url)
    var imageData = Data()
    print("Download Started")
    let urlRequest = NSURLRequest(url: fileUrl!)
    let urlConnection: NSURLConnection = NSURLConnection(request: urlRequest as URLRequest, delegate: self)!
    getDataFromUrl(url: fileUrl!) { (data, response, error)  in

      if let error = error {

        print(error)
      } else {
        if let data = data {

          imageData = data
        }
      }
      completion(data, response, error)
    }
  }

  func saveImageToCoreData(title: String, url: String, completion: @escaping CompletionHandler) {

    downloadImage(title: title, url: url) { data, response, error in

      if error != nil {
        print(error!)
        completion(nil, response, error)
      } else {
        completion(data, response, nil)
      }
    }
  }
}


