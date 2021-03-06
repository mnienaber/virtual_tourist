//
//  ViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 10/27/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//  first final

import UIKit
import MapKit
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, UIApplicationDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

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

    mapView.showsUserLocation = true

    showPins()

    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()

    appDelegate = UIApplication.shared.delegate as! AppDelegate

    let longTap: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapVC.action(gestureRecognizer:)))

    longTap.delegate = self
    longTap.numberOfTapsRequired = 0
    longTap.minimumPressDuration = 0.5
    longTap.allowableMovement = 10
    mapView.addGestureRecognizer(longTap)

    printDatabaseStatistics()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    zoomViewSettings()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !savedRegionLoaded{
      checkMapZoom()
    }
    savedRegionLoaded = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    print("viewWillAppear - showPins()")
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

    FailAlerts.sharedInstance().failGenOK(title: "Location not found", message: "Your device's location was not found, you can still continue to use the app", alerttitle: "OK")
  }

  func action(gestureRecognizer:UIGestureRecognizer) {

    let touchPoint = gestureRecognizer.location(in: self.mapView)
//    var newCoord:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)

    let newAnnotation = MKPointAnnotation()
//    newAnnotation.coordinate = newCoord
//    newCoord.latitude = newAnnotation.coordinate.latitude
//    newCoord.longitude = newAnnotation.coordinate.longitude
    if gestureRecognizer.state == .ended {
      let touchPoint = gestureRecognizer.location(in: mapView)
      let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
      newAnnotation.coordinate = newCoordinates
      coordinatesForPin = newCoordinates
      let annotation = MKPointAnnotation()
      annotation.coordinate = newCoordinates
      annotation.title = "See Photos"
      mapView.addAnnotation(newAnnotation)
      let pin = Pin(latitude: Float(newCoordinates.latitude), longitude: Float(newCoordinates.longitude), context: self.delegate.stack.context)
      print("pin: \(pin)")
      self.delegate.stack.save()
      showPins()
      print("action - showpins")
    }
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?){
    if segue.identifier == "tappedPin" {
      let collectionVC = segue.destination as! PhotosVC

      collectionVC.pinSelected = currentPin!
      collectionVC.detailLocation = coordinatesForPin
    }
  }

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let identifier = "pin"
    var view: MKPinAnnotationView
    if let dequeuedView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
      dequeuedView.annotation = annotation
      view = dequeuedView
    } else {
      view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      view.canShowCallout = false
      view.isEnabled = true
    }
    return view
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

    coordinatesForPin = (view.annotation?.coordinate)!

    let pin = self.getPin(latitude: coordinatesForPin.latitude, longitude: coordinatesForPin.longitude)
    if pin != nil, pin!.count > 0{
      currentPin = pin!.first!
    }
    performSegue(withIdentifier: "tappedPin", sender: self)
  }

  func showPins() {
    let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")

    let pins: [Pin]? = fetchPin(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)

    guard pins != nil else {
      return
    }

    mapView.removeAnnotations(mapView.annotations)

    mapView.addAnnotations(pins!.map { pin in
      let annotation = MKPointAnnotation()
      annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
      annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
      return annotation
    })
  }

  func fetchPin(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [Pin]? {
    var pins: [Pin]?

    do {
      pins = try self.delegate.stack.context.fetch(fetchRequest) as? [Pin]

    } catch {
      FailAlerts.sharedInstance().failGenOK(title: "Pins not located", message: "No pins were found", alerttitle: "OK")
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

