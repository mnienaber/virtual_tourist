////
////  CollectionViewController.swift
////  virtual_tourist
////
////  Created by Michael Nienaber on 11/2/16.
////  Copyright © 2016 Michael Nienaber. All rights reserved.
////

import Foundation
import UIKit
import MapKit
import CoreData

class CollectionViewController:  CoreDataCollectionViewController {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var bottomActionOutlet: UIBarButtonItem!

  var pinSelected: Pin?
  var detailLocation = CLLocationCoordinate2D()
  let delegate = UIApplication.shared.delegate as! AppDelegate


  //var selectedIndexes = [IndexPath]()
//  var insertedIndexPaths: [IndexPath]!
//  var deletedIndexPaths: [IndexPath]!
//  var updatedIndexPaths: [IndexPath]!

  // MARK: - View Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()

    let annotation = MKPointAnnotation()
    annotation.coordinate.latitude = CLLocationDegrees((pinSelected?.latitude)!)
    annotation.coordinate.longitude = CLLocationDegrees((pinSelected?.longitude)!)
    self.mapView.addAnnotation(annotation)
    bottomActionOutlet.title = "New Photo Album"

    showPin()

    // Create a fetchrequest
    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    fr.predicate = NSPredicate(format: "pin = %@", pinSelected!)
    fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

    // Create the FetchedResultsController
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)

    if Reachability.isConnectedToNetwork() == false {

      performUIUpdatesOnMain {
        FailAlerts.sharedInstance().failGenOK(title: "No Connection", message: "You don't seem to be connected to the internet", alerttitle: "I'll fix it!")
      }
    } else {
      print("1")
      Client.sharedInstance().getImages(pin: pinSelected!) { results, error in

        if results {
          print("ImageObjectDetail.sharedInstance().pictures: \(ImageObjectDetail.sharedInstance().pictures)")
          self.saveImagesToContext(images: ImageObjectDetail.sharedInstance().pictures, pin: self.pinSelected!)
        }
      }
    }
  }

  func saveImagesToContext(images:[ImageObject], pin: Pin) {

    self.delegate.stack.context.perform(){

      for image in images {
        print("image: \(image)")
        //Create a Photo ManagedObject with the info we get from the network
        _ = Photos.corePhotoWithNetworkInfo(pictureInfo: image, pinUsed: pin,inManagedObjectContext: self.delegate.stack.context)
      }
      self.collectionView.reloadData()
      self.delegate.stack.save()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    self.delegate.stack.autoSave(60)
    self.collectionView.reloadData()

  }



  // MARK: - UICollectionView
  func configureCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
//    let photo = self.fetchedResultsController?.object(at: indexPath)
//
//    if let image = UIImage(data: photo.image!,scale:1.0) {
//
//      cell.activityIndicator.isHidden = true
//      cell.colorPanel.isHidden = true
//      //cell.imageView.image = image
//    }
    if let _ = selectedIndexes.index(of: indexPath) {
      cell.alpha = 0.05
    } else {
      cell.alpha = 1.0
    }
  }


  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
    if let index = selectedIndexes.index(of: indexPath) {
      selectedIndexes.remove(at: index)
      cell.colorPanel.isHidden = true
      //updateBottomButton()
      print("deselected")
    } else {
      cell.colorPanel.isHidden = false
      selectedIndexes.append(indexPath)
      //updateBottomButton()
      print("selected")
    }
  }

  // MARK: - Fetched Results Controller Delegate

  // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
  // three fresh arrays to record the index paths that will be changed.
//  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//    // We are about to handle some new changes. Start out with empty arrays for each change type
//    insertedIndexPaths = [IndexPath]()
//    deletedIndexPaths = [IndexPath]()
//    updatedIndexPaths = [IndexPath]()
//
//    print("in controllerWillChangeContent")
//  }

  // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
  // We store the index paths into the three arrays.
//
//
//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//    switch type {
//
//    case .insert:
//      print("Insert an item")
//      // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
//      // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
//      // the index path that we want in this case
//      insertedIndexPaths.append(newIndexPath!)
//      break
//    case .delete:
//      print("Delete an item")
//      // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
//      // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
//      // value that we want in this case.
//      deletedIndexPaths.append(indexPath!)
//      break
//    case .update:
//      print("Update an item.")
//      // We don't expect Color instances to change after they are created. But Core Data would
//      // notify us of changes if any occured. This can be useful if you want to respond to changes
//      // that come about after data is downloaded. For example, when an image is downloaded from
//      // Flickr in the Virtual Tourist app
//      updatedIndexPaths.append(indexPath!)
//      break
//    case .move:
//      print("Move an item. We don't expect to see this in this app.")
//      break
//      //default:
//      //break
//    }
//  }

  // This method is invoked after all of the changed objects in the current batch have been collected
  // into the three index path arrays (insert, delete, and upate). We now need to loop through the
  // arrays and perform the changes.
  //
  // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
  // Notice that all of the changes are performed inside a closure that is handed to the collection view.
//  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//
//    print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
//
//    collectionView.performBatchUpdates({() -> Void in
//
//      for indexPath in self.insertedIndexPaths {
//        self.collectionView.insertItems(at: [indexPath])
//      }
//
//      for indexPath in self.deletedIndexPaths {
//        self.collectionView.deleteItems(at: [indexPath])
//      }
//
//      for indexPath in self.updatedIndexPaths {
//        self.collectionView.reloadItems(at: [indexPath])
//      }
//
//    }, completion: nil)
//  }

//  func deleteAllPhotos() {
//
//    for photos in (fetchedResultsController?.fetchedObjects!)! {
//      self.delegate.stack.context.delete(photos as! NSManagedObject)
//    }
//  }
//
//  func deleteSeletedPhotos() {
//
//    var photosToDelete = [Photos]()
//
//    for indexPath in selectedIndexes {
//
//      photosToDelete.append(fetchedResultsController!.object(at: indexPath) as! Photos)
//    }
//
//    for deadPhoto in photosToDelete {
//
//      print("dead photo")
//      self.delegate.stack.context.delete(deadPhoto)
//      bottomActionOutlet.title = "New Photo Album"
//    }
//
//    selectedIndexes = [IndexPath]()
//
//    do {
//      try self.delegate.stack.context.save()
//    } catch {
//      print("coundn't save context for some reason")
//    }
//    bottomActionOutlet.title = "New Photo Album"
//  }
//
//  func updateBottomButton() {
//
//    if selectedIndexes.count > 0 {
//
//      bottomActionOutlet.title = "Remove Images"
//    } else {
//      selectedIndexes.removeAll()
//      bottomActionOutlet.title = "New Photo Album"
//    }
//  }



  func getFlickrPhotos(lat: Float, long: Float, completion: @escaping (_ success: Bool, _ error: String?) -> Void) {

    performBackgroundUpdatesOnGlobal {
      Client.sharedInstance().getImages(pin: self.pinSelected!) { results, error in

        if error != nil {

          performUIUpdatesOnMain {
            print(error)
            FailAlerts.sharedInstance().failGenOK(title: "No Images", message: "Your search returned no images", alerttitle: "Try Again")
            completion(false, "Something went wrong")
          }
        } else {

          print("results: \(results)")
          completion(true, "nothing to see here")
        }
      }
    }
  }

  func getPhotos() -> [Photos]? {

    var photos: [Photos]?
    do {
      photos = try self.delegate.stack.context.fetch((fetchedResultsController?.fetchRequest)!) as! [Photos]
    } catch {
      FailAlerts.sharedInstance().failGenOK(title: "Sorry", message: "Couldn't load photos", alerttitle: "Please try again")
    }
    return photos
  }

  func showPin() {

    var annotations = [MKPointAnnotation]()

    let coordinate = detailLocation
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegionMake(coordinate, span)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotations.append(annotation)
    self.mapView.addAnnotations(annotations)
    self.mapView.setRegion(region, animated: true)
  }

  @IBAction func bottomAction(_ sender: Any) {

    if bottomActionOutlet.title == "Remove Images" {

      //deleteSeletedPhotos()
      print("deleteselectedphotos")
    } else {

      performBackgroundUpdatesOnGlobal {

        self.getFlickrPhotos(lat: Float(self.detailLocation.latitude), long: Float(self.detailLocation.longitude)) { (success, error) in
          if success {
            self.delegate.stack.save()
          } else {
            print("something went wrong")
          }
        }
      }
    }
  }

  @IBAction func backButton(_ sender: Any) {
    
    print("baaaack")

    let _ = self.navigationController?.popToRootViewController(animated: true)
  }
}









