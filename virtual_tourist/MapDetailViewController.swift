//
//  MapDetailViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 2/4/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapDetailViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

  var images = [NSManagedObject]()
  let locationManager = CLLocationManager()
  var locations = CLLocationCoordinate2D()

  @IBOutlet weak var mapView: MKMapView!


  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.mapView.delegate = self
  }

//  override func viewWillAppear(animated: Bool) {
//
//    self.navigationController?.isNavigationBarHidden = true
//  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let reuseId = "pin"

    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinTintColor = .red
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }

    return pinView
  }


  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

    if control == view.rightCalloutAccessoryView {

      let app = UIApplication.shared
      if let toOpen = view.annotation?.subtitle! {

        app.openURL(NSURL(string: toOpen)! as URL)
      }
    }
  }


}
