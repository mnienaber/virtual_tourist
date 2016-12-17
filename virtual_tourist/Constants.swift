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
  }
}
