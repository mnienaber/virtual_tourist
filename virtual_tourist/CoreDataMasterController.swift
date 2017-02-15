//
//  CoreDataMasterController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 1/27/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import UIKit
import CoreData

class CoreDataMasterController: UIViewController {

  var blockOperations: [BlockOperation] = []

  // MARK:  - Properties
  var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
    didSet{
      // Whenever the frc changes, we execute the search and
      // reload the table
      fetchedResultsController?.delegate = self
      executeSearch()
      collectionView?.reloadData()
    }
  }

  init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>,
       style : UITableViewStyle = .plain){
    fetchedResultsController = fc
  }

  // Do not worry about this initializer. I has to be implemented
  // because of the way Swift interfaces with an Objective C
  // protocol called NSArchiving. It's not relevant.
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }


}


// MARK:  - Fetches
extension CoreDataMasterController{

  func executeSearch(){
    if let fc = fetchedResultsController{
      do{
        try fc.performFetch()
      }catch let e as NSError{
        print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
      }
    }
  }
}


// MARK:  - Delegate
extension CoreDataMasterController: NSFetchedResultsControllerDelegate{

//
//  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    collectionView?.beginUpdates()
//  }
//
//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                  didChange sectionInfo: NSFetchedResultsSectionInfo,
//                  atSectionIndex sectionIndex: Int,
//                  for type: NSFetchedResultsChangeType) {
//
//    let set = IndexSet(integer: sectionIndex)
//
//    switch (type){
//
//    case .insert:
//      collectionView?.insertSections(
//
//    case .delete:
//      collectionView?.deleteSections(.fade)
//
//    default:
//      // irrelevant in our case
//      break
//
//    }
//  }


//  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
//                  didChange anObject: Any,
//                  at indexPath: IndexPath?,
//                  for type: NSFetchedResultsChangeType,
//                  newIndexPath: IndexPath?) {
//
//
//
//    switch(type){
//
//    case .insert:
//      tableView.insertRows(at: [newIndexPath!], with: .fade)
//
//    case .delete:
//      tableView.deleteRows(at: [indexPath!], with: .fade)
//
//    case .update:
//      tableView.reloadRows(at: [indexPath!], with: .fade)
//
//    case .move:
//      tableView.deleteRows(at: [indexPath!], with: .fade)
//      tableView.insertRows(at: [newIndexPath!], with: .fade)
//    }
//
//  }
//
//  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//    tableView.endUpdates()
//  }
}
