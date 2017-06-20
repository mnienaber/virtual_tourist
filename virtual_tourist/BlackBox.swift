//
//  BlackBox.swift
//  itunes_lookup
//
//  Created by Michael Nienaber on 8/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
  DispatchQueue.main.async {
    updates()
  }
}

func performBackgroundUpdatesOnGlobal(_ updates: @escaping () -> Void) {
  DispatchQueue.global(qos: .background).async {
    updates()
  }
}



