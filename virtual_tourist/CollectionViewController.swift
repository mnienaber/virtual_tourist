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

class CollectionViewController:  CoreDataMasterController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!
  @IBOutlet weak var photoCollectionView: UICollectionView!
  @IBOutlet weak var imageView: UIImageView!


  var image : Photos?

  let delegate = UIApplication.shared.delegate as! AppDelegate



  override func viewDidLoad() {
    super.viewDidLoad()

    photoCollectionView.delegate = self
    photoCollectionView.dataSource = self


    // Set the title
    title = "Photo View"

    // Get the stack
    let stack = delegate.stack

//    // Create a fetchrequest
    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]

    // Create the FetchedResultsController
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)

    // Do any additional setup after loading the view, typically from a nib.
  }

  func photoCollectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    let numberOfItems = self.fetchedResultsController?.sections?[section]

    return (numberOfItems?.numberOfObjects)!
  }

  func photoCollectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {}



  func configureCell(cell: CollectionViewCell) -> <#return type#> {
    <#function body#>
}
