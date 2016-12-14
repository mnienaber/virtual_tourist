////
////  CollectionViewController.swift
////  virtual_tourist
////
////  Created by Michael Nienaber on 11/2/16.
////  Copyright © 2016 Michael Nienaber. All rights reserved.
////
//
//import Foundation
//import UIKit
//import MapKit
//
//class CollectionViewController: UICollectionViewController, MKMapViewDelegate, CLLocationManagerDelegate {
//
//  @IBOutlet weak var miniMapView: MKMapView!
//  @IBOutlet weak var bottomToolBar: UIToolbar!
//  @IBOutlet weak var photoCollectionView: UICollectionView!
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    // Do any additional setup after loading the view, typically from a nib.
//  }
//
//  override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//  }
//
//  var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
//    didSet {
//      // Whenever the frc changes, we execute the search and
//      // reload the table
//      fetchedResultsController?.delegate = self
//      executeSearch()
//      tableView.reloadData()
//    }
//  }
//
//  // MARK: Initializers
//
//  init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UICollectionViewStyle = .plain) {
//    fetchedResultsController = fc
//    super.init(style: style)
//  }
//
//  // Do not worry about this initializer. I has to be implemented
//  // because of the way Swift interfaces with an Objective C
//  // protocol called NSArchiving. It's not relevant.
//  required init?(coder aDecoder: NSCoder) {
//    super.init(coder: aDecoder)
//  }
//}
//
//// MARK: - CoreDataTableViewController (Subclass Must Implement)
//
//extension CoreDataTableViewController {
//
//  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
//  }
//}
