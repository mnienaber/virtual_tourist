//
//  CollectionViewController.swift
//  virtual_tourist
//
//  Created by Michael Nienaber on 11/2/16.
//  Copyright © 2016 Michael Nienaber. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotosVC:  CoreDataViewController {

  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var backButton: UIBarButtonItem!
  @IBOutlet weak var bottomActionOutlet: UIBarButtonItem!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

  var pinSelected: Pin?
  var detailLocation = CLLocationCoordinate2D()
  let delegate = UIApplication.shared.delegate as! AppDelegate
  let delayValue = 100

  override func viewDidLoad() {
    super.viewDidLoad()

    let annotation = MKPointAnnotation()
    annotation.coordinate.latitude = CLLocationDegrees((pinSelected?.latitude)!)
    annotation.coordinate.longitude = CLLocationDegrees((pinSelected?.longitude)!)
    self.mapView.addAnnotation(annotation)
    bottomActionOutlet.title = "New Photo Album"

    setupFlowLayout()
    showPin()

    print(pinSelected!)

    let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photos")
    fr.predicate = NSPredicate(format: "pin = %@", pinSelected!)
    fr.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: self.delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)

//    do {
//      try fetchedResultsController?.performFetch()
//    } catch {
//      print("nothing return")
//    }

//    if pinSelected?.photos?.count != nil, (pinSelected?.photos?.count)! > 0 {
//
//      print("we have photos")
//    } else {
//      print("get new photos")
//      if Reachability.isConnectedToNetwork() == false {
//
//        performUIUpdatesOnMain {
//          FailAlerts.sharedInstance().failGenOK(title: "No Connection", message: "You don't seem to be connected to the internet", alerttitle: "I'll fix it!")
//        }
//      } else {
//
//        print("1")
//        Client.sharedInstance().getImages(pin: pinSelected!) { results, error in
//          if results {
//            print("8")
//            self.saveImagesToContext(images: ImageObjectDetail.sharedInstance().pictures, pin: self.pinSelected!)
//          }
//        }
//      }
//    }
    switch pinSelected {
    case _ where (pinSelected?.photos?.count)! > 0:
      print("we have photos")
      print("fr.predicate: \(String(describing: fr.predicate))")

    default:
      print("get new photos")
      if Reachability.isConnectedToNetwork() == false {

        performUIUpdatesOnMain {
          FailAlerts.sharedInstance().failGenOK(title: "No Connection", message: "You don't seem to be connected to the internet", alerttitle: "I'll fix it!")
        }
      } else {

        print("1")
        Client.sharedInstance().getImages(pin: pinSelected!) { results, error in
          if results {
            print("8")
            self.saveImagesToContext(images: ImageObjectDetail.sharedInstance().pictures, pin: self.pinSelected!)
          }
        }
      }
    }
  }

  func saveImagesToContext(images:[ImageObject], pin: Pin) {

    self.delegate.stack.context.perform(){
      print("9")

      for image in images {

        _ = Photos.corePhotoWithNetworkInfo(pictureInfo: image, pinUsed: pin,inManagedObjectContext: self.delegate.stack.context)
      }
      self.delegate.stack.save()
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.delegate.stack.autoSave(delayValue)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
    if let index = selectedIndexes.index(of: indexPath) {

      selectedIndexes.remove(at: index)
      cell.colorPanel.isHidden = true
      updateBottomButton()
      print("deselected")
    } else {

      cell.colorPanel.isHidden = false
      selectedIndexes.append(indexPath)
      updateBottomButton()
      print("selected")
    }
  }

  func getPhotos() -> [Photos]? {

    var photos: [Photos]?
    do {

      photos = try self.delegate.stack.context.fetch((fetchedResultsController?.fetchRequest)!) as? [Photos]
    } catch {

      FailAlerts.sharedInstance().failGenOK(title: "Sorry", message: "Couldn't load photos", alerttitle: "Please try again")
    }
    return photos
  }

  func showPin() {

    var annotations = [MKPointAnnotation]()

    let coordinate = detailLocation
    let span = MKCoordinateSpanMake(0.05, 0.05)
    let region = MKCoordinateRegionMake(coordinate, span)
    let annotation = MKPointAnnotation()
    annotation.coordinate = coordinate
    annotations.append(annotation)
    self.mapView.addAnnotations(annotations)
    self.mapView.setRegion(region, animated: true)
  }

  @IBAction func bottomAction(_ sender: Any) {

    if bottomActionOutlet.title == "Remove Images" {

      deleteSeletedPhotos()
      print("deleteselectedphotos")
      bottomActionOutlet.title = "New Photo Album"
    } else {

      if Reachability.isConnectedToNetwork() == false {

        performUIUpdatesOnMain {
          FailAlerts.sharedInstance().failGenOK(title: "No Connection", message: "You don't seem to be connected to the internet", alerttitle: "I'll fix it!")
        }
      } else {
        print("1")

        let currentPhotos = getPhotos()
        if currentPhotos != nil {

          for photos in currentPhotos! {

            self.delegate.stack.context.delete(photos)
          }
        }
        
        Client.sharedInstance().getImages(pin: pinSelected!) { results, error in

          if results {

            print("8")
            self.saveImagesToContext(images: ImageObjectDetail.sharedInstance().pictures, pin: self.pinSelected!)
          }
        }
      }
    }
  }

  func setupFlowLayout() {
    
    let space: CGFloat = 3
    let dimension = (view.frame.width - 2 * space) / 3

    flowLayout.minimumLineSpacing = space
    flowLayout.minimumInteritemSpacing = space
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)
  }

  func deleteSeletedPhotos() {

    var photosToDelete = [Photos]()

    for indexPath in selectedIndexes {

      photosToDelete.append(fetchedResultsController!.object(at: indexPath) as! Photos)
    }

    for deadPhoto in photosToDelete {

      self.delegate.stack.context.delete(deadPhoto)
      print("dead photo")
    }
    selectedIndexes = [IndexPath]()
  }

  @IBAction func backButton(_ sender: Any) {
    
    print("back")
    let _ = self.navigationController?.popToRootViewController(animated: true)
  }

  func updateBottomButton() {

    if selectedIndexes.count > 0 {

      bottomActionOutlet.title = "Remove Images"
    } else {
      
      bottomActionOutlet.title = "New Photo Album"
    }
  }
}









