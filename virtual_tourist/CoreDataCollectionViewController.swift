//  Constants.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 12/17/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  @IBOutlet weak var collectionView: UICollectionView!

  var selectedIndexes = [IndexPath]()

  typealias collectionViewOperation = () -> Void
  var blockOperations = [collectionViewOperation]()

  var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
    didSet {

      fetchedResultsController?.delegate = self
      executeSearch()
      self.collectionView?.reloadData()
    }
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

extension CoreDataCollectionViewController {

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell

    cell.imageView.image = UIImage(named: "placeholder")
    cell.activityIndicator.startAnimating()
    cell.imageView.contentMode = .scaleAspectFit
    cell.colorPanel.isHidden = true

    let photo = self.fetchedResultsController?.object(at: indexPath) as? Photos
    print("photonumner: \(photo)")

    if photo?.image == nil {

      let url = photo?.url
      _ = Client.sharedInstance().getImageData(url!) { data, error in
        if let image = UIImage(data: data!) {

          performUIUpdatesOnMain {
            cell.imageView.image = image
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
    return cell
  }
}

extension CoreDataCollectionViewController {

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if let fc = fetchedResultsController {
      return (fc.sections?.count)!
    } else {
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let fc = fetchedResultsController {
      print("fc: \(fc.sections![section].numberOfObjects)")
      return fc.sections![section].numberOfObjects
    } else {
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let yourWidth = collectionView.bounds.width/3.0
    let yourHeight = yourWidth

    return CGSize(width: yourWidth, height: yourHeight)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0,0,0,0)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }

}

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

extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    blockOperations.removeAll()
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView.performBatchUpdates({
      for operation in self.blockOperations {
        operation()
      }
    }, completion: nil)
  }

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
