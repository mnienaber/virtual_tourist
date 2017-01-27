//
//  TableViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 1/27/17.
//  Copyright © 2017 Michael Nienaber. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDataSource {

  @IBOutlet weak var tableView: UITableView!

var images = [NSManagedObject]()

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "\"The List\""
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
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")

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

    let person = images[indexPath.row]

    cell!.textLabel!.text =
      person.value(forKey: "name") as? String

    return cell!
  }

  @IBAction func addName(_ sender: Any) {

    let alert = UIAlertController(title: "New Name",
                                  message: "Add a new name",
                                  preferredStyle: .alert)

    let saveAction = UIAlertAction(title: "Save",
                                   style: .default,
                                   handler: { (action:UIAlertAction) -> Void in

                                    let textField = alert.textFields!.first
                                    self.saveName(name: textField!.text!)
                                    self.tableView.reloadData()
    })

    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default) { (action: UIAlertAction) -> Void in
    }

    alert.addTextField {
      (textField: UITextField) -> Void in
    }

    alert.addAction(saveAction)
    alert.addAction(cancelAction)

    present(alert,
            animated: true,
            completion: nil)
  }

  func saveName(name: String) {
    //1
    let appDelegate =
      UIApplication.shared.delegate as! AppDelegate

    let managedContext = appDelegate.persistentContainer.viewContext

    //2
    let entity =  NSEntityDescription.entity(forEntityName: "Person",
                                             in:managedContext)

    let person = NSManagedObject(entity: entity!,
                                 insertInto: managedContext)

    //3
    person.setValue(name, forKey: "name")

    //4
    do {
      try managedContext.save()
      //5
      images.append(person)
    } catch let error as NSError  {
      print("Could not save \(error), \(error.userInfo)")
    }
  }

}
