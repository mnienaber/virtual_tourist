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

class CollectionViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!
  @IBOutlet weak var photoCollectionView: UICollectionView!
  @IBOutlet weak var imageView: UIImageView!


  var image : Photos?

  let delegate = UIApplication.shared.delegate as! AppDelegate

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set the title
    title = "Photo View"

    // Get the stack
    let stack = delegate.stack

//    // Create a fetchrequest
    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

    // Create the FetchedResultsController

    fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
  }



extension CollectionViewController {
  //1
  func photoCollectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    let numberOfItems = self.fetchedResultsController?.sections?[section]
    return (numberOfItems?.numberOfObjects)!
  }

  func photoCollectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! CollectionViewCell
    cell.backgroundColor = UIColor.black
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {

    let numberOfItems = self.fetchedResultsController?.sections?[section]
    return (numberOfItems?.numberOfObjects)!
  }
  }
}
