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

  func taskForGETMethod(request: NSURLRequest, methodArguments: [String: AnyObject], completionHandlerForGET: @escaping (_ result: Bool, _ error: NSError?) -> Void) -> URLSessionDataTask {

    let task = session.dataTask(with: request as URLRequest) { data, response, error in

      func sendError(_ error: String) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        completionHandlerForGET(false, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
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
      self.convertDataWithCompletionHandler(data, methodArguments: methodArguments, completionHandlerForConvertData: completionHandlerForGET)
    }
    task.resume()
    return task
  }

  func convertDataWithCompletionHandler(_ data: Data, methodArguments: [String: AnyObject], completionHandlerForConvertData: @escaping (_ result: Bool, _ error: NSError?) -> Void) {

    var parsedResult: [String:AnyObject]!
    do {
      parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
    } catch {
      let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
      completionHandlerForConvertData(false, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }

    if let photosDictionary = parsedResult[Client.Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] {

      self.pickARandomPage(photosDictionary: photosDictionary, methodArguments: methodArguments) { (success, error) in
        if success{
          completionHandlerForConvertData(true, nil)
        } else {
          completionHandlerForConvertData(false, error)
        }
      }
    }
  }

  func pickARandomPage(photosDictionary: [String: AnyObject], methodArguments: [String: AnyObject], completionHandlerForImages: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
    guard let totalPages = photosDictionary[Client.Constants.FlickrResponseKeys.Pages] as? Int else {
      print("Found no pages in photos dictionary")
      return
    }

    guard totalPages >= 0 else {
      print("Found no pages in photos dictionary")
      return
    }
    // pick a random page!
    let pageLimit = min(totalPages, 40)
    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
    print("randomPage: \(randomPage)")
    downloadRandomFlickrAlbum(methodArguments: methodArguments, withPageNumber: randomPage){ (success, error) in
      if success{
        completionHandlerForImages(true, nil)
      } else{
        completionHandlerForImages(false, error)
      }
    }
  }

  func downloadRandomFlickrAlbum(methodArguments: [String: AnyObject], withPageNumber pageNumber: Int? = nil, completionHandlerForImages: @escaping (_ success: Bool, _ error: NSError?) -> Void){

    var methodArguments = methodArguments
    
    methodArguments[Client.Constants.FlickrParameterKeys.Page] = pageNumber as AnyObject
    print("pageNumber: \(pageNumber)")
    //methodArguments[Client.Constants.FlickrParameterKeys.perPage] = 20 as AnyObject

    let urlString = Client.Constants.Scheme.BASE_URL + escapedParameters(parameters: methodArguments as [String : AnyObject])
    let url = NSURL(string: urlString)!

    // create session and request
    let session = URLSession.shared
    let request = URLRequest(url: url as URL)

    // create network request
    let task = session.dataTask(with: request) { (data, response, error) in


      /* GUARD: Was there an error? */
      guard (error == nil) else {
        completionHandlerForImages(false, error! as NSError)
        return
      }

      /* GUARD: Did we get a successful 2XX response? */
      guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
        completionHandlerForImages(false, error! as NSError)
        return
      }

      /* GUARD: Was there any data returned? */
      guard let data = data else {
        completionHandlerForImages(false, error! as NSError)
        return
      }

      // parse the data
      let parsedResult: [String:AnyObject]!
      do {
        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
      } catch {
        completionHandlerForImages(false, error as NSError)
        return
      }

      /* GUARD: Did Flickr return an error (stat != ok)? */
      guard let stat = parsedResult[Client.Constants.FlickrResponseKeys.Status] as? String, stat == Client.Constants.FlickrResponseValues.OKStatus else {
        completionHandlerForImages(false, error! as NSError)
        return
      }
      //print("This is the parsedResult: \(parsedResult)")

      // GUARD: Is "photos" key in our result? We now have a photos dictionary
      if let photosDictionary = parsedResult[Client.Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] {

        guard let photosArray = photosDictionary[Client.Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
          completionHandlerForImages(false, error! as NSError)
          return
        }

        //Store the pictures from the results in a shared instance.
        ImageObject.SLOFromResults(photosArray){(finishedConverting, pictures) in
          if finishedConverting {
            ImageObjectDetail.sharedInstance().pictures = pictures
            print("pictures: \(pictures)")
            completionHandlerForImages(true, nil)
          }
        }

      } else {
        completionHandlerForImages(false, error! as NSError)
        print("Couldn't find photos.")
      }
    }
    task.resume()
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

