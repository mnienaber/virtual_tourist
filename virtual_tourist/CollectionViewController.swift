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

class CollectionViewController: UICollectionViewController, MKMapViewDelegate, CLLocationManagerDelegate {

  @IBOutlet weak var miniMapView: MKMapView!
  @IBOutlet weak var bottomToolBar: UIToolbar!
  @IBOutlet weak var photoCollectionView: UICollectionView!

  var blockOperations: [BlockOperation] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
    blockOperations.removeAll(keepingCapacity: false)
  }

  func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    if type == NSFetchedResultsChangeType.insert {
      print("insert Object: \(newIndexPath)")

      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.insertItems(at: [newIndexPath! as IndexPath])
          }
        })
      )
    }
    else if type == NSFetchedResultsChangeType.update {
      print("Update Object: \(indexPath)")
      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.reloadItems(at: [indexPath! as IndexPath])
          }
        })
      )
    }
    else if type == NSFetchedResultsChangeType.move {
      print("move Object: \(indexPath)")

      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.moveItem(at: indexPath! as IndexPath, to: newIndexPath! as IndexPath)
          }
        })
      )
    }
    else if type == NSFetchedResultsChangeType.delete {
      print("Delete Object: \(indexPath)")

      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.deleteItems(at: [indexPath! as IndexPath])
          }
        })
      )
    }
  }

  func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {

    if type == NSFetchedResultsChangeType.insert {
      print("insert Section: \(sectionIndex)")

      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
          }
        })
      )
    }
    else if type == NSFetchedResultsChangeType.update {
      print("Update Section: \(sectionIndex)")
      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
          }
        })
      )
    }
    else if type == NSFetchedResultsChangeType.delete {
      print("Delete Section: \(sectionIndex)")

      blockOperations.append(
        BlockOperation(block: { [weak self] in
          if let this = self {
            this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
          }
        })
      )
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView!.performBatchUpdates({ () -> Void in
      for operation: BlockOperation in self.blockOperations {
        operation.start()
      }
    }, completion: { (finished) -> Void in
      self.blockOperations.removeAll(keepingCapacity: false)
    })
  }
}
