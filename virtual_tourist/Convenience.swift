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

  func getImages(latitude: Float, longitude: Float, completionHanderForGetImages: @escaping (_ results: Bool, _ error: NSError?) -> Void) {

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

            self.saveImageToCoreData(title: title as! String, url: url as! String)
          }
        }
        completionHanderForGetImages(true, nil)
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

  func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {

    URLSession.shared.dataTask(with: url) {
      (data, response, error) in
      completion(data, response, error)
      }.resume()
  }

  func saveImageToCoreData(title: String, url: String) {
    //1
    let appDelegate =
      UIApplication.shared.delegate as! AppDelegate

    let managedContext = appDelegate.persistentContainer.viewContext

    //2
    let entity =  NSEntityDescription.entity(forEntityName: "Photos",
                                             in:managedContext)

    let image = NSManagedObject(entity: entity!,
                                insertInto: managedContext)
    //3
    image.setValue(title, forKey: "title")
    image.setValue(url, forKey: "url")
    image.setValue(Client.sharedInstance().latitude, forKey: "latitude")
    image.setValue(Client.sharedInstance().longitude, forKey: "longitude")


    //4
    do {
      try managedContext.save()
      //5
      Client.sharedInstance().photoManagedObject.append(image)
      print("managedobject: \(Client.sharedInstance().photoManagedObject)")
    } catch let error as NSError  {
      print("Could not save \(error), \(error.userInfo)")
    }
  }

  func savePin(lat: Float, long: Float) {

    let appDelegate =
      UIApplication.shared.delegate as! AppDelegate

    let managedContext = appDelegate.persistentContainer.viewContext

    //2
    let entity =  NSEntityDescription.entity(forEntityName: "Photos",
                                             in:managedContext)

    let image = NSManagedObject(entity: entity!,
                                insertInto: managedContext)
    //3
    image.setValue(lat, forKey: "latitude")
    image.setValue(long, forKey: "longitude")

    // we save our entity
    do {
      try managedContext.save()
    } catch {
      fatalError("Failure to save context: \(error)")
    }
  }
}


