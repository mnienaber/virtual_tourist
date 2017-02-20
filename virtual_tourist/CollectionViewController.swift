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

class CollectionViewController:  UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!
  @IBOutlet weak var photoCollectionView: UICollectionView!
  @IBOutlet weak var imageView: UIImageView!

  let delegate = UIApplication.shared.delegate as! AppDelegate

  // MARK: - Instance Variables
  lazy var fetchedResultsController: NSFetchedResultsController<Photos> = { () -> NSFetchedResultsController<Photos> in

    let fetchRequest = NSFetchRequest<Photos>(entityName: "Photos")
    fetchRequest.sortDescriptors = []

    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.delegate.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
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

    let width = floor(self.photoCollectionView.frame.size.width/3)
    layout.itemSize = CGSize(width: width, height: width)
    photoCollectionView.collectionViewLayout = layout
  }

  // MARK: - UICollectionView
  func configureCell(_ cell: CollectionViewCell, atIndexPath indexPath: IndexPath) {
    print("in configureCell")
    let photo = self.fetchedResultsController.object(at: indexPath)

    if let image = UIImage(data: photo.image!,scale:1.0) {

      cell.imageView.image = image
    }

    // If the cell is "selected", its color panel is grayed out
    // we use the Swift `find` function to see if the indexPath is in the array

    if let _ = selectedIndexes.index(of: indexPath) {
      cell.colorPanel.alpha = 0.05
    } else {
      cell.colorPanel.alpha = 1.0
    }
  }

}





