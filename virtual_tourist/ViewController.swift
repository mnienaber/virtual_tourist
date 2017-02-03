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

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!
  
  override func viewDidLoad() {
    super.viewDidLoad()

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
    if gestureRecognizer.state == .began {
      mapView.addAnnotation(newAnnotation)
      Client.sharedInstance().latitude = Float(newCoord.latitude)
      Client.sharedInstance().longitude = Float(newCoord.longitude)
      Client.sharedInstance().getImages(latitude: Client.sharedInstance().latitude, longitude: Client.sharedInstance().longitude) { results, error in

        if error != nil {

          performUIUpdatesOnMain {
            print(error)
          }
        } else {

          performUIUpdatesOnMain {
            self.bottomToolBar.isHidden = false
          }
        }
      }
    }
  }

//  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//    print("Pin Tapped")
//    let pin = view.annotation as! CoreDataTableViewController
//        performSegue(withIdentifier: "pinTapped", sender: pin)
//        print("tapped pin 1")
//  }

  func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pinTapped" {
      let viewController = segue.destination as! CoreDataTableViewController
      viewController.images = sender as! [NSManagedObject]
      print("pin tapped 2")
    }
  }
//
//
//  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//    //When pin is tapped, segue to Collection View Controller
//    let pin = view.annotation as! CoreDataTableViewController
//    performSegue(withIdentifier: "pinTapped", sender: pin)
//    print("tapped pin 1")
//  }
//
//  func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//
//    if segue.identifier == "pinTapped" {
//
//      let collectionVC = segue.destination as! CoreDataTableViewController
//      collectionVC.images = sender as! [NSManagedObject]
//      print("tapped pin 2")
//    }
//  }

  public func bottomToolBarStatus(hidden: Bool) {
    bottomToolBar.isHidden = hidden

    if hidden {
      bottomToolBar.isHidden = true
    } else {
      bottomToolBar.isHidden = false
    }
  }

}

