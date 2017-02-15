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

//  lazy var frcPin: NSFetchedResultsController<Pin> = { () -> NSFetchedResultsController<Pin> in
//
//    let fetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
//    fetchRequest.sortDescriptors = []
//
//    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
//    fetchedResultsController.delegate = self
//
//    return fetchedResultsController
//  }()
//
//  var sharedContext = self.appDelegate.shared.managedObjectContext!

  override func viewDidLoad() {
    super.viewDidLoad()
    //CoreDataStack.dropAllData(CoreDataStack: self)

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

            print("results: \(results)")
            self.bottomToolBar.isHidden = false
          }
        }
      }
    }
  }

  // In a storyboard-based application, you will often want to do a little preparation before navigation
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    // Get the new view controller using segue.destinationViewController.
//    // Pass the selected object to the new view controller.
//
//    if segue.identifier! == "displayNote"{
//
//      if let photosVC = segue.destination as? ViewController {
//
//        // Create Fetch Request
//        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
//
//        fr.sortDescriptors = [NSSortDescriptor(key: "image", ascending: false),
//                              NSSortDescriptor(key: "title", ascending: true)]
//
//        // So far we have a search that will match ALL notes. However, we're
//        // only interested in those within the current notebook:
//        // NSPredicate to the rescue!
//        let indexPath = mapView.indexPathForSelectedRow!
//        let notebook = fetchedResultsController?.object(at: indexPath) as? Notebook
//
//        let pred = NSPredicate(format: "notebook = %@", argumentArray: [notebook!])
//
//        fr.predicate = pred
//
//        // Create FetchedResultsController
//        let fc = NSFetchedResultsController(fetchRequest: fr,
//                                            managedObjectContext:fetchedResultsController!.managedObjectContext,
//                                            sectionNameKeyPath: "humanReadableAge",
//                                            cacheName: nil)
//
//        // Inject it into the notesVC
//        notesVC.fetchedResultsController = fc
//
//        // Inject the notebook too!
//        notesVC.notebook = notebook
//
//      }
//    }
//  }



  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let annotation = annotation
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
    print("tapped")

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

