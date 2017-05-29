////  Constants.swift
////  virtual_tourist
////
////  Created by Michael Nienaber on 12/17/16.
////  Copyright © 2016 Michael Nienaber. All rights reserved.
////
//
import UIKit
import CoreData
//
////Used as an example for our UICollectionViewController.
//
//// MARK: - CoreDataCollectionViewController: UITableViewController

class CoreDataCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

  @IBOutlet weak var collectionView: UICollectionView!
  // MARK: Properties

  var selectedIndexes = [IndexPath]()

  //Use blockOperations array to stre operations.
  typealias collectionViewOperation = () -> Void
  var blockOperations = [collectionViewOperation]()

  var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
    didSet {
      // Whenever the frc changes, we execute the search and
      // reload the table
      fetchedResultsController?.delegate = self
      executeSearch()
      self.collectionView?.reloadData()
    }
  }

  // MARK: Initializers
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

// MARK: - CoreDataCollectionViewController - Images to be shown for each collectionView Cell.

extension CoreDataCollectionViewController {

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

    cell.imageView.image = UIImage(named: "placeholder")
    cell.activityIndicator.startAnimating()
    cell.imageView.contentMode = .scaleAspectFit

    let photo = self.fetchedResultsController?.object(at: indexPath) as? Photos
    print("let photo = self.fetchedResultsController.object(at: indexPath): \(photo)")

    if photo?.image == nil {

      let url = photo?.url
      _ = Client.sharedInstance().getImageData(url: url!) { data, response, error in
        if let image = UIImage(data: data!) {
          print("image: \(image)")
          performUIUpdatesOnMain {
            cell.imageView!.image = image
            cell.activityIndicator.stopAnimating()
          }
        } else {
          print(error)
          cell.activityIndicator.stopAnimating()
        }
      }
    } else {
      cell.activityIndicator.stopAnimating()
      cell.imageView.image = UIImage(data: (photo?.image)! as Data)
    }

    //Used for correct highlight of selected images while scrolling.
    if let _ = self.selectedIndexes.index(of: indexPath) {
      cell.alpha = 0.05
    } else {
      cell.alpha = 1.0
    }

    return cell
  }
}

// MARK: - CoreDataCollectionViewController (CollectionView Data Source)

extension CoreDataCollectionViewController {

  //How many sections?
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if let fc = fetchedResultsController {
      return (fc.sections?.count)!
    } else {
      return 0
    }
  }

  //How many items per section?
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let fc = fetchedResultsController {
      return fc.sections![section].numberOfObjects
    } else {
      return 0
    }
  }

}

// MARK: - CoreDataTableViewController (Fetches)

extension CoreDataCollectionViewController {

  func executeSearch() {
    if let fc = fetchedResultsController {
      do {
        try fc.performFetch()
      } catch let e as NSError {
        print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
      }
    }
  }
}

// MARK: - CoreDataTableViewController: NSFetchedResultsControllerDelegate

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {

  //Remove operations when controller is about to change
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    blockOperations.removeAll()
  }

  // Let collectionview know that content changes and should perform operations
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView.performBatchUpdates({
      for operation in self.blockOperations {
        operation()
      }
    }, completion: nil)
  }

  // Notify collectionView that there is a change for a section.
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {

    let set = IndexSet(integer: sectionIndex)

    switch type {
    case .insert:
      blockOperations.append({
        self.collectionView.insertSections(set)
      })
    case .delete:
      blockOperations.append({
        self.collectionView.deleteSections(set)
      })
    default:
      break
    }
  }

  // Notify collectionView that an object has been changed.
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

    switch type {
    case .insert:

      blockOperations.append({
        self.collectionView.insertItems(at: [newIndexPath!])
      })
    case .delete:
      blockOperations.append({
        self.collectionView.deleteItems(at: [indexPath!])
      })
    case .move:
      blockOperations.append({
        self.collectionView.deleteItems(at: [indexPath!])
        self.collectionView.insertItems(at: [newIndexPath!])
      })
    case .update:
      blockOperations.append({
        self.collectionView.reloadItems(at: [indexPath!])
      })
    }
  }
}
