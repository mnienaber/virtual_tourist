//
//  Constants.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation


extension Client {

  struct  Constants {

    struct Scheme {

      static let BASE_URL = "https://api.flickr.com/services/rest/"
      static let METHOD_NAME = "flickr.photos.search"
      static let API_KEY = "a2d1aaeead83f40edc51928ef2caf6a9"
      static let EXTRAS = "url_m"
      static let DATA_FORMAT = "json"
      static let NO_JSON_CALLBACK = "1"
      static let PER_PAGE = "20"
    }

    struct ParseResponseKeys {

      static let Farm = "farm"
      static let Height = "height"
      static let Id = "id"
      static let IsFamily = "isFamiliy"
      static let IsFriend = "isFriend"
      static let IsPubic = "isPublic"
      static let Owner = "owner"
      static let Secret = "secret"
      static let Server = "server"
      static let Title = "title"
      static let ImageUrl = "imageurl"
      static let Width = "width"
      static let Data = "data"
    }

    struct FlickrResponseKeys {
      static let Status = "stat"
      static let Photos = "photos"
      static let Photo = "photo"
      static let Title = "title"
      static let MediumURL = "url_m"
      static let Pages = "pages"
      static let Total = "total"
      static let id = "id"
    }

    struct FlickrParameterKeys {
      static let Method = "method"
      static let APIKey = "api_key"
      static let GalleryID = "gallery_id"
      static let Extras = "extras"
      static let Format = "format"
      static let NoJSONCallback = "nojsoncallback"
      static let SafeSearch = "safe_search"
      static let Text = "text"
      static let BoundingBox = "bbox"
      static let Page = "page"
      static let perPage = "per page"
    }

    struct MapCoordinates {

      static let latitude = "latitude"
      static let longitude = "longitude"
    }

    struct FlickrResponseValues {
      static let OKStatus = "ok"
    }

    struct JSONResponseKeys {

      static let FlickrResults = "photos"
    }

    struct ZoomKeys {
      static let Lat = "CenterLat"
      static let Lon = "CenterLon"
      static let Alt = "altitude"
      static let Pitch = "pitch"
    }

    struct BottomToolBarStatus {
      static var status = true
    }
  }
}
