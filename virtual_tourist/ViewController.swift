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
  var zoomAlt = CLLocationDistance()
  var zoomLon = CLLocationDegrees()
  var zoomLat = CLLocationDegrees()
  var savedRegionLoaded = false
  let delegate = UIApplication.shared.delegate as! AppDelegate

  @IBOutlet weak var mapView: MKMapView!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.mapView.delegate = self
    mapView.showsUserLocation = true

    showPins()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    appDelegate = UIApplication.shared.delegate as! AppDelegate

    let longTap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.action(gestureRecognizer:)))

    longTap.delegate = self
    longTap.numberOfTapsRequired = 0
    longTap.minimumPressDuration = 0.5
    longTap.allowableMovement = 10
    mapView.addGestureRecognizer(longTap)

    printDatabaseStatistics()
  }

  override func viewWillDisappear(_ animated: Bool) {
    zoomViewSettings()
  }

  override func viewDidAppear(_ animated: Bool) {
    if !savedRegionLoaded{
      checkMapZoom()
    }
    savedRegionLoaded = true
  }

  override func viewWillAppear(_ animated: Bool) {
    print("viewwillappear")
    showPins()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

    if userChangedMapViewZoom() {

      zoomViewSettings()
    }
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

    let touchPoint = gestureRecognizer.location(in: self.mapView)
    var newCoord:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)

    let newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = newCoord
    newCoord.latitude = newAnnotation.coordinate.latitude
    newCoord.longitude = newAnnotation.coordinate.longitude
    if gestureRecognizer.state == .ended {
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      coordinatesForPin = newCoordinates
      let annotation = MKPointAnnotation()
      annotation.coordinate = newCoordinates
      annotation.title = "See Photos"
      mapView.addAnnotation(newAnnotation)
      let pin = Pin(latitude: Float(newCoord.latitude), longitude: Float(newCoord.longitude), context: self.delegate.stack.context)
      print("pin: \(pin)")
      self.delegate.stack.save()
      self.showPins()
    }
  }

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

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    print("tapped")
    coordinatesForPin = (view.annotation?.coordinate)!
    var pin = self.getPin(latitude: coordinatesForPin.latitude, longitude: coordinatesForPin.longitude)
    currentPin = pin!.removeFirst()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    if segue.identifier == "tappedPin" {
      print("you've been tapped")
      //let nav = segue.destination as! UINavigationController
      let collectionVC = segue.destination as! CollectionViewController
      collectionVC.pinSelected = currentPin!
      collectionVC.detailLocation = coordinatesForPin
    }
  }

  //If callout is clicked then segue.
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    if control == view.rightCalloutAccessoryView {
      performSegue(withIdentifier: "tappedPin", sender: self)

    }
  }

  func showPins() {
    let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")

    let pins: [Pin]? = fetchPin(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

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
      pins = try self.delegate.stack.context.fetch(fetchRequest) as? [Pin]
      print("pins from function: \(try self.delegate.stack.context.count(for: fetchRequest))") //returns a valid number of pins
    } catch {
      print("whoops")
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

  func printDatabaseStatistics() {
    let pinCount = try? self.delegate.stack.context.count(for: NSFetchRequest(entityName: "Pin"))
    let photoCount = try? self.delegate.stack.context.count(for: NSFetchRequest(entityName: "Photos"))
    print("\(String(describing: pinCount)) Pins Found")
    print("\(String(describing: photoCount)) Photos Found")
  }

  func checkMapZoom(){
    if let altitude = UserDefaults.standard.value(forKey: Client.Constants.ZoomKeys.Alt){
      mapView.camera.altitude = altitude as! CLLocationDistance
    } else{
      UserDefaults.standard.set(mapView.camera.altitude, forKey: Client.Constants.ZoomKeys.Alt)
    }

    if let cameraCenterLatitude = UserDefaults.standard.value(forKey: Client.Constants.ZoomKeys.Lat){
      mapView.camera.centerCoordinate.latitude = cameraCenterLatitude as! CLLocationDegrees
    } else {
      UserDefaults.standard.set(mapView.camera.centerCoordinate.latitude, forKey: Client.Constants.ZoomKeys.Lat)
    }

    if let cameraCenterLongitude = UserDefaults.standard.value(forKey: Client.Constants.ZoomKeys.Lon){
      mapView.camera.centerCoordinate.longitude = cameraCenterLongitude as! CLLocationDegrees
    } else {
      UserDefaults.standard.set(mapView.camera.centerCoordinate.longitude, forKey: Client.Constants.ZoomKeys.Lon)
    }

    print(mapView.camera.centerCoordinate as Any)

  }

  func zoomViewSettings() {
    zoomAlt = mapView.camera.altitude
    zoomLat = mapView.camera.centerCoordinate.latitude
    zoomLon = mapView.camera.centerCoordinate.longitude

    UserDefaults.standard.set(zoomAlt, forKey: Client.Constants.ZoomKeys.Alt)
    UserDefaults.standard.set(zoomLat, forKey: Client.Constants.ZoomKeys.Lat)
    UserDefaults.standard.set(zoomLon, forKey: Client.Constants.ZoomKeys.Lon)
    UserDefaults.standard.synchronize()
  }

  func userChangedMapViewZoom() -> Bool {

    let view = self.mapView.subviews[0]

    if let gestureRecognizers = view.gestureRecognizers {

      for recog in gestureRecognizers {

        if (recog.state == UIGestureRecognizerState.began || recog.state == UIGestureRecognizerState.ended) {

          return true
        }
      }
    }
    return false
  }
}

