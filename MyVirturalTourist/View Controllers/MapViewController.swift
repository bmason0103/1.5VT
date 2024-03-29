//
//  MapViewController.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/3/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData


class MapViewController: UIViewController  {
    
    struct Pin {
        let lat: Double
        let long: Double
    }
    
      var dataController:DataController!
      var fetchedResultsController:NSFetchedResultsController<ThePin>!

    
    
    //MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    var pinAnnotation: MKPointAnnotation? = nil
    var cityName = ""
    
    //MARK: Pre-setup
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setTapsForMaps()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
//              setupFetchedResultsController()
             
          }
    
    fileprivate func setTapsForMaps() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        singleTap.numberOfTapsRequired = 3
        singleTap.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(singleTap)
    }
    //MARK: Get coordinates from user tap and add pin to map
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            //Now use this coordinate to add annotation on map.
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Set title and subtitle if you want
            
            Constants.Coordinate.latitude = coordinate.latitude
            Constants.Coordinate.longitude = coordinate.longitude
            print("This is constant", Constants.Coordinate.longitude)
           
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            geoCoder.reverseGeocodeLocation(location, completionHandler:
                {
                    placemarks, error -> Void in
                    
                    // Place details
                    guard let placeMark = placemarks?.first else { return }
                    
                    // City
                    if let city = placeMark.subAdministrativeArea {
                        print(city)
                       
                        self.cityName = city
                        print(self.cityName)
                        annotation.title = self.cityName
                    }
                    
            }
                
            )
            
            Constants.Coordinate.city = cityName
            annotation.subtitle = "subtitle"
            self.mapView.addAnnotation(annotation)
            print(Constants.Coordinate.city, "saved name")

        }
    }

    //MARK: Setting up Fetch request for previously created pins
    fileprivate func setupFetchedResultsControllerPins() {
          let fetchRequest:NSFetchRequest<ThePin> = ThePin.fetchRequest()
          let sortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
          fetchRequest.sortDescriptors = [sortDescriptor]

          fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "savedPins")
        fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
          do {
              try fetchedResultsController.performFetch()
          } catch {
              fatalError("The fetch could not be performed: \(error.localizedDescription)")
          }
      }

    //MARK: Setting up Fetch request for previously created photo collections
       fileprivate func setupFetchedResultsControllerPhotos() {
             let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
             let sortDescriptor = NSSortDescriptor(key: "URL", ascending: false)
             fetchRequest.sortDescriptors = [sortDescriptor]

             fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "savedAlbum")
        fetchedResultsController.delegate = (self as! NSFetchedResultsControllerDelegate)
             do {
                 try fetchedResultsController.performFetch()
             } catch {
                 fatalError("The fetch could not be performed: \(error.localizedDescription)")
             }
         }
    
        private func loadAllPins() -> [Pin]? {
            let pins: [Pin]?
               do {
    //            try pins = DataController.shared().fetchAllPins(entityName: ThePin)
               } catch {
                   print("\(#function) error:\(error)")
                   displayAlert(title: "Error", message: "Error while fetching Pin locations: \(error)")
               }
               return pins
           }
//MARK: This will be made an IB Action later
    func deleteAction(_ sender: Any) {
           // delete all photos
           for photos in fetchedResultsController.fetchedObjects! {
               DataController.shared().viewContext.delete(photos)
           }
//        DataController.saveContext()
//        addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer)
       }
    //MARK: Passing coordinates to next Picture view Controller
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionViewSegue" {
            if let collectionVC = segue.destination as? collectionViewController {
                let sender = sender as! Pin
                collectionVC.latitude = sender.lat
                collectionVC.longitude = sender.long
               
            }
        }
    }
    
    
    
}
//MARK: MKMapViewDelegate
//*********************************************//
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
          //Add code in here about transitioning to other view
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation else {
            return
        }

        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        let pin = Pin(lat:lat,long:lon)
        //        {
//            if isEditing {
//                mapView.removeAnnotation(annotation)
//                CoreDataStack.shared().context.delete(pin)
//                save()
                return
            
            performSegue(withIdentifier: "collectionViewSegue", sender: pin)
        }
    }
    
    
    









