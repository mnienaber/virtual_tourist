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

//  private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
//
//    var components = URLComponents()
//    components.scheme = Client.Constants
//    components.host = VTConstants.Flickr.APIHost
//    components.path = VTConstants.Flickr.APIPath
//    components.queryItems = [URLQueryItem]()
//
//    for (key, value) in parameters {
//      let queryItem = URLQueryItem(name: key, value: "\(value)")
//      components.queryItems!.append(queryItem)
//    }
//
//    return components.url!
//  }

  func getImages(pin: Pin, completionHanderForGetImages: @escaping (_ results: Bool, _ error: Error?) -> Void) {

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

    taskForGETMethod(request: request, methodArguments: methodArguments as [String : AnyObject] ) { results, error in

      if let error = error {

        completionHanderForGetImages(false, error)
      } else {

        print("success: \(results)")

//        if let results = results[Client.Constants.JSONResponseKeys.FlickrResults] as? [String:AnyObject] {
//
//          let images = results[Client.Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
//
//          for result in images! {
//            let title = result["title"]
//            let url = result["url_m"]
//
//
//
//           self.getImageData(title: title as! String, url: url as! String) { data, response, error in
//
//              if error != nil {
//
//                print(error!)
//                completionHanderForGetImages(false, error)
//              } else {
//
//                print("success")
//              }
//            }
          }
        }
        completionHanderForGetImages(true, nil)
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
      print("pin managedContext \(managedContext)")
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

  func getImageData(url: String, completion: @escaping CompletionHandler) {

    downloadImage(url: url) { data, response, error in

      if error != nil {
        print(error!)
        completion(nil, response, error)
      } else {
        completion(data, response, nil)
      }
    }
  }

  func downloadImage(url: String, completion: @escaping CompletionHandler) {

    let fileUrl = URL(string: url)
    var imageData = Data()
    print("Download Started")
    getDataFromUrl(url: fileUrl!) { (data, response, error)  in

      if let error = error {
        print(error)
      } else {
        if let data = data {
          imageData = data
        }
      }
      print("Download completed: \(imageData)")
      completion(data, response, error)
    }
  }

  func getDataFromUrl(url: URL, completion: @escaping CompletionHandler) {

    URLSession.shared.dataTask(with: url) {
      (data, response, error) in
      completion(data, response, error)
      }.resume()
  }


//  func saveImagesToContext(images: [Photos], pin: Pin) {
//    appDelegate.stack.context.perform {
//      for image in images {
//        _ = Photos.corePhotoWithNetworkInfo(pictureInfo: image, pinUsed: pin, imageData: <#Data#>, inManagedObjectContext: self.appDelegate.stack.context)
//      }
//    }
//
//      self.appDelegate.stack.save()
//    }
}


