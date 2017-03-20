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

class CollectionViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate, UICollectionViewDataSourcePrefetching, CLLocationManagerDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var bottomActionOutlet: UIBarButtonItem!

  var pinSelected: Pin?
  var detailLocation = CLLocationCoordinate2D()
  let lat: Float = -35.19809
  let long: Float = 141.7202
  let delegate = UIApplication.shared.delegate as! AppDelegate

  // MARK: - Instance Variables
  lazy var fetchedResultsController: NSFetchedResultsController<Photos> = { () -> NSFetchedResultsController<Photos> in

    let fetchRequest = NSFetchRequest<Photos>(entityName: "Photos")
    let latSort = NSSortDescriptor(key: "latitude", ascending: true)
    fetchRequest.sortDescriptors = [latSort]

    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self

    return fetchedResultsController
  }()

  var selectedIndexes = [IndexPath]()
  // Keep the changes. We will keep track of insertions, deletions, and updates.
  var insertedIndexPaths: [IndexPath]!
  var deletedIndexPaths: [IndexPath]!
  var updatedIndexPaths: [IndexPath]!

  // MARK: - View Lifecycle Methods
  override func viewDidLoad() {
    print("in viewDidLoad()")

    super.viewDidLoad()

    bottomActionOutlet.title = "New Photo Album"

    let annotation = MKPointAnnotation()

    //TODO: segue will include selected pin cordinates - hard coded for now.
//    annotation.coordinate.latitude = CLLocationDegrees((detailLocation.latitude))
//    annotation.coordinate.latitude = CLLocationDegrees((detailLocation.longitude))
    annotation.coordinate.latitude = CLLocationDegrees((-35.19809))
    annotation.coordinate.longitude = CLLocationDegrees((141.7202))
    self.mapView.addAnnotation(annotation)

    // Start the fetched results controller
    var error: NSError?
    do {
      try fetchedResultsController.performFetch()
    } catch let error1 as NSError {
      error = error1
    }

    if let error = error {
      print("Error performing initial fetch: \(error)")
    }
  }

  override func viewDidLayoutSubviews() {
    print("in viewDidLayoutSubviews()")
    super.viewDidLayoutSubviews()

    // Layout the collection view so that cells take up 1/3 of the width,
    // with no space in-between.
    let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0

    let width = floor(self.collectionView.frame.size.width/3)
    layout.itemSize = CGSize(width: width, height: width)
    collectionView.collectionViewLayout = layout
  }

  // MARK: - UICollectionView
  func configureCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
    print("in configureCell")
    let photo = self.fetchedResultsController.object(at: indexPath)

    if let image = UIImage(data: photo.image!,scale:1.0) {

      cell.activityIndicator.isHidden = true
      cell.colorPanel.isHidden = true
      cell.imageView.image = image
    }

    // If the cell is "selected", its color panel is grayed out
    // we use the Swift `find` function to see if the indexPath is in the array
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    print("in numberOfSectionsInCollectionView()")
    return self.fetchedResultsController.sections?.count ?? 0
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print("in collectionView(_:numberOfItemsInSection)")
    let sectionInfo = self.fetchedResultsController.sections![section]

    print("number Of Cells: \(sectionInfo.numberOfObjects)")
    return sectionInfo.numberOfObjects
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    print("in collectionView(_:cellForItemAtIndexPath)")

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

    cell.imageView.image = UIImage(named: "placeholder")
    cell.activityIndicator.startAnimating()
    cell.imageView.contentMode = .scaleAspectFit

    let photo = self.fetchedResultsController.object(at: indexPath) as? Photos

    if photo?.image == nil {
      performBackgroundUpdatesOnGlobal {

        self.getFlickrPhotos(lat: self.lat, long: self.lat)
      }
    } else {
      cell.activityIndicator.stopAnimating()
      self.configureCell(cell, atIndexPath: indexPath)
    }
    //If there is already and image downloaded for that indexPath, the show it.
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    collectionView.prefetchDataSource = nil
    collectionView.isPrefetchingEnabled = false
  }

  func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    collectionView.prefetchDataSource = nil
    collectionView.isPrefetchingEnabled = false
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
    if let index = selectedIndexes.index(of: indexPath) {
      selectedIndexes.remove(at: index)
      cell.colorPanel.isHidden = true
      updateBottomButton()
      print("deselected")
    } else {
      cell.colorPanel.isHidden = false
      selectedIndexes.append(indexPath)
      updateBottomButton()
      print("selected")
    }
  }

  // MARK: - Fetched Results Controller Delegate

  // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
  // three fresh arrays to record the index paths that will be changed.
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    // We are about to handle some new changes. Start out with empty arrays for each change type
    insertedIndexPaths = [IndexPath]()
    deletedIndexPaths = [IndexPath]()
    updatedIndexPaths = [IndexPath]()

    print("in controllerWillChangeContent")
  }

  // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
  // We store the index paths into the three arrays.


  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {

    case .insert:
      print("Insert an item")
      // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
      // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
      // the index path that we want in this case
      insertedIndexPaths.append(newIndexPath!)
      break
    case .delete:
      print("Delete an item")
      // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
      // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
      // value that we want in this case.
      deletedIndexPaths.append(indexPath!)
      break
    case .update:
      print("Update an item.")
      // We don't expect Color instances to change after they are created. But Core Data would
      // notify us of changes if any occured. This can be useful if you want to respond to changes
      // that come about after data is downloaded. For example, when an image is downloaded from
      // Flickr in the Virtual Tourist app
      updatedIndexPaths.append(indexPath!)
      break
    case .move:
      print("Move an item. We don't expect to see this in this app.")
      break
      //default:
      //break
    }
  }

  // This method is invoked after all of the changed objects in the current batch have been collected
  // into the three index path arrays (insert, delete, and upate). We now need to loop through the
  // arrays and perform the changes.
  //
  // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
  // Notice that all of the changes are performed inside a closure that is handed to the collection view.
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")

    collectionView?.performBatchUpdates({() -> Void in

      for indexPath in self.insertedIndexPaths {
        self.collectionView.insertItems(at: [indexPath])
      }

      for indexPath in self.deletedIndexPaths {
        self.collectionView.deleteItems(at: [indexPath])
      }

      for indexPath in self.updatedIndexPaths {
        self.collectionView.reloadItems(at: [indexPath])
      }

    }, completion: nil)
  }

  func deleteAllPhotos() {

    for photos in fetchedResultsController.fetchedObjects! {
      self.delegate.stack.context.delete(photos)
    }
  }

  func deleteSeletedPhotos() {

    var photosToDelete = [Photos]()

    for indexPath in selectedIndexes {

      photosToDelete.append(fetchedResultsController.object(at: indexPath))
    }

    for deadPhoto in photosToDelete {

      print("dead photo")
      self.delegate.stack.context.delete(deadPhoto)
      bottomActionOutlet.title = "New Photo Album"
    }

    selectedIndexes = [IndexPath]()

    do {
      try self.delegate.stack.context.save()
    } catch {
      print("coundn't save context for some reason")
    }
    bottomActionOutlet.title = "New Photo Album"
  }

  func updateBottomButton() {

    if selectedIndexes.count > 0 {

      bottomActionOutlet.title = "Remove Images"
    } else {
      selectedIndexes.removeAll()
      bottomActionOutlet.title = "New Photo Album"
    }
  }

  func getFlickrPhotos(lat: Float, long: Float) -> Bool {

    performBackgroundUpdatesOnGlobal {
      Client.sharedInstance().getImages(latitude: Client.sharedInstance().latitude, longitude: Client.sharedInstance().longitude) { results, error in

        if error != nil {

          performUIUpdatesOnMain {
            print(error)
            FailAlerts.sharedInstance().failGenOK(title: "No Images", message: "Your search returned no images", alerttitle: "Try Again")
            return
          }
        } else {

          print("results: \(results)")
        }
      }
    }
    print("true")
    return true
  }

  //Check if there are Photos in the database.
  func getPhotos() -> [Photos]? {

    var photos: [Photos]?
    do {
      photos = try self.delegate.stack.context.fetch(fetchedResultsController.fetchRequest) as [Photos]
    } catch {
      FailAlerts.sharedInstance().failGenOK(title: "Sorry", message: "Couldn't load photos", alerttitle: "Please try again")
    }

    return photos
  }

  @IBAction func bottomAction(_ sender: Any) {

    if bottomActionOutlet.title == "Remove Images" {

      deleteSeletedPhotos()
      print("deleteselectedphotos")
    } else {

      performBackgroundUpdatesOnGlobal {
        Client.sharedInstance().getImages(latitude: Client.sharedInstance().latitude, longitude: Client.sharedInstance().longitude) { results, error in

          if error != nil {

            performUIUpdatesOnMain {
              print(error)
              FailAlerts.sharedInstance().failGenOK(title: "No Images", message: "Your search returned no images", alerttitle: "Try Again")
              return
            }
          } else {

            print("results of bottomaction: \(results)")
          }
        }
      }
    }
  }
}

















