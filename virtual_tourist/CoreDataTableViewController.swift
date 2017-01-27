//
//  TableViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 1/27/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!

var images = [NSManagedObject]()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\"The Location List\""
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let stack = delegate.stack
    
    tableView.register(UITableViewCell.self,
                       forCellReuseIdentifier: "Cell")
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    //1
    let appDelegate =
      UIApplication.shared.delegate as! AppDelegate

    let managedContext = appDelegate.persistentContainer.viewContext

    //2
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")

    //3
    do {
      let results =
        try managedContext.fetch(fetchRequest)
      images = results as! [NSManagedObject]
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return images.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt
    indexPath: IndexPath) -> UITableViewCell {

    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell")

    let images = self.images[indexPath.row]

    cell!.textLabel!.text =
      images.value(forKey: "title") as? String
    cell!.detailTextLabel!.text = images.value(forKey: "url") as? String

    return cell!
  }
}
