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

//  func didLongTapMap(gestureRecognizer: UIGestureRecognizer) {
//    print("long tap detected")
//    // Get the spot that was tapped.
//    let tapPoint: CGPoint = gestureRecognizer.location(in: mapView)
//    let touchMapCoordinate: CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)
//
//    let viewAtBottomOfHierarchy: UIView = mapView.hitTest(tapPoint, with: nil)!
//    if viewAtBottomOfHierarchy is MKPinAnnotationView {
//      return
//    } else {
//      if .began == gestureRecognizer.state {
//        // Delete any existing annotations.
//        if mapView.annotations.count != 0 {
//          mapView.removeAnnotations(mapView.annotations)
//        }
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = touchMapCoordinate
//        print(annotation.coordinate.latitude)
//        print(annotation.coordinate.longitude)
//
//
//        mapView.addAnnotation(annotation)
//        print("wheres the pin")
//        //_isPinOnMap = true
//
//        //findAddressFromCoordinate(annotation.coordinate)
//        //updateLabels()
//      }
//    }
//  }

  func action(gestureRecognizer:UIGestureRecognizer) {
    let touchPoint = gestureRecognizer.location(in: self.mapView)
    var newCoord:CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)

    var pm = [CLPlacemark]()

    let newAnnotation = MKPointAnnotation()
    newAnnotation.coordinate = newCoord
    newAnnotation.title = "New Location"
    newAnnotation.subtitle = "New Subtitle"
    newCoord.latitude = newAnnotation.coordinate.latitude
    newCoord.longitude = newAnnotation.coordinate.longitude
    //pm.append(["name":"\(newAnnotation.title)","latitude":"\(newCoord.latitude)","longitude":"\(newCoord.longitude)"])
    if gestureRecognizer.state == .began {
      mapView.addAnnotation(newAnnotation)
      savePin(lat: Float(newCoord.latitude), long: Float(newCoord.longitude), locationName: newAnnotation.title!)
      print(newCoord.latitude)
      print(newCoord.longitude)
      Client.sharedInstance().getImages(latitude: newCoord.latitude, longitude: newCoord.longitude) { results, error in

        if error != nil {

          performUIUpdatesOnMain {
            print(error)
          }
        } else {

          if let results = results {

            performUIUpdatesOnMain {
              for result in results {

                let newImageUrl = result.imageUrl

              }
            }
          }
        }
      }
    }
  }

  func savePin(lat: Float, long: Float, locationName: String) {

    // create an instance of our managedObjectContext
    let moc = CoreDataStack(modelName: "Pin")?.context

    // we set up our entity by selecting the entity and context that we're targeting
    let entity = NSEntityDescription.insertNewObject(forEntityName: "Pin", into: moc!) as! Pin

    // add our data
    entity.setValue(lat, forKey: "latitude")
    entity.setValue(long, forKey: "longitude")
    entity.setValue(locationName, forKey: "locationName")

    // we save our entity
    do {
      try moc?.save()
    } catch {
      fatalError("Failure to save context: \(error)")
    }
  }
}

