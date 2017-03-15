//
//  ViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 10/27/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController, MKMapViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

  var appDelegate: AppDelegate!
  let locationManager = CLLocationManager()
  let regionRadius: CLLocationDistance = 100
  var coordinatesForPin = CLLocationCoordinate2D()
  var currentPin: Pin?
  var pin: Pin?

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!

  override func viewDidLoad() {
    super.viewDidLoad()

//    do {
//      try self.appDelegate.stack.dropAllData()
//    } catch {
//      print(error as? NSError)
//    }

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    mapView.delegate = self
    mapView.showsUserLocation = true
    bottomToolBar.isHidden = true

    appDelegate = UIApplication.shared.delegate as! AppDelegate

    let longTap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(gestureRecognizer:)))

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

  func action(gestureRecognizer:UIGestureRecognizer) {

    bottomToolBar.isHidden = true
    let touchPoint = gestureRecognizer.location(in: self.mapView)
    var newCoord:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)

    let newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = newCoord
    newCoord.latitude = newAnnotation.coordinate.latitude
    newCoord.longitude = newAnnotation.coordinate.longitude
    if gestureRecognizer.state == .ended {
      mapView.addAnnotation(newAnnotation)
      Client.sharedInstance().latitude = Float(newCoord.latitude)
      Client.sharedInstance().longitude = Float(newCoord.longitude)
      Client.sharedInstance().savePinToCoreData(lat: Client.sharedInstance().latitude, long: Client.sharedInstance().longitude)
      Client.sharedInstance().getImages(latitude: Client.sharedInstance().latitude, longitude: Client.sharedInstance().longitude) { results, error in

        if error != nil {

          performUIUpdatesOnMain {
            print(error)
          }
        } else {

          performUIUpdatesOnMain {

            print("results: \(results)")
            self.bottomToolBar.isHidden = false
            self.appDelegate.stack.save()
          }
        }
      }
    }
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let reuseId = "pin"

    var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
      pinView!.canShowCallout = true
      pinView!.pinColor = .green
      pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }
    else {
      pinView!.annotation = annotation
    }

    return pinView
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    if segue.identifier == "tappedPin"{
      let collectionVC = segue.destination as! CollectionViewController
      collectionVC.pinSelected = currentPin!
      collectionVC.detailLocation = coordinatesForPin
    }
  }

  //If callout is clicked then segue.
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
      //TODO: Create
      performSegue(withIdentifier: "tappedPin", sender: self)

    }
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("tapped")
    coordinatesForPin = (view.annotation?.coordinate)!
    let pin = self.getPin(latitude: coordinatesForPin.latitude, longitude: coordinatesForPin.longitude)

    if pin != nil, pin!.count > 0 {
      currentPin = pin!.first!
    }
  }

  func showPins() {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")

    let pins: [Pin]? = fetchPin(fetchRequest: fetchRequest)

    guard pins != nil else {
      return
    }

    mapView.addAnnotations(pins!.map { pin in
      let annotation = MKPointAnnotation()
      annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
      annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
      annotation.title = "See Photos"
      return annotation
    })
  }

  func fetchPin(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [Pin]? {
    var pins: [Pin]?

    do {
      pins = try appDelegate.stack.context.fetch(fetchRequest) as? [Pin]
    } catch {
      print("whoops")
      //VTClient.sharedInstance().showAlert(controller: self, title: "Could not load pins", message: "Try again")
    }
    return pins
  }

  func getPin(latitude: CLLocationDegrees, longitude: CLLocationDegrees) -> [Pin]? {
    let fetchRequest = getFetchRequest(entityName: "Pin", format: "latitude = %@ && longitude = %@", argArray: [latitude, longitude])

    let pins: [Pin]? = fetchPin(fetchRequest: fetchRequest)

    return pins
  }

  func getFetchRequest(entityName: String, format: String, argArray: [Any]?) -> NSFetchRequest<NSFetchRequestResult> {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)

    let predicate = NSPredicate(format: format, argumentArray: argArray)
    fetchRequest.predicate = predicate

    return fetchRequest
  }

  public func bottomToolBarStatus(hidden: Bool) {
    bottomToolBar.isHidden = hidden

    if hidden {
      bottomToolBar.isHidden = true
    } else {
      bottomToolBar.isHidden = false
    }
  }

}

