//
//  ViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 10/27/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

  var appDelegate: AppDelegate!
  let locationManager = CLLocationManager()
  let regionRadius: CLLocationDistance = 2000

  @IBOutlet weak var mapView: MKMapView!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    mapView.delegate = self
    mapView.showsUserLocation = true

    appDelegate = UIApplication.shared.delegate as! AppDelegate

    let longTap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(mapView.addAnnotation(_:)))

    longTap.delegate = self
    longTap.numberOfTapsRequired = 0
    longTap.minimumPressDuration = 0.5
    longTap.allowableMovement = 10
    mapView.addGestureRecognizer(longTap)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

    if status == .authorizedWhenInUse {
    }
  }

  private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    let location = locations.last
    let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.65, longitudeDelta: 0.65))

    mapView.setRegion(region, animated: true)
    locationManager.stopUpdatingLocation()
  }

  private func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {

    print("error:: \(error)")
  }

  func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
    print("long tap detected")
    // Get the spot that was tapped.
    let tapPoint: CGPoint = gestureRecognizer.location(in: mapView)
    let touchMapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)

    let viewAtBottomOfHierarchy: UIView = mapView.hitTest(tapPoint, with: nil)!
    if viewAtBottomOfHierarchy is MKPinAnnotationView {
      return
    } else {
      if .began == gestureRecognizer.state {
        // Delete any existing annotations.
        if mapView.annotations.count != 0 {
          mapView.removeAnnotations(mapView.annotations)
        }

        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        print(annotation.coordinate.latitude)
        print(annotation.coordinate.longitude)


        mapView.addAnnotation(annotation)
        print("wheres the pin")
        //_isPinOnMap = true

        //findAddressFromCoordinate(annotation.coordinate)
        //updateLabels()
      }
    }
  }

}

