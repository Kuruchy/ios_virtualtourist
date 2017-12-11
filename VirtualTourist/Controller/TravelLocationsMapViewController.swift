//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 01.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController {

    // MARK: Variables
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var editMode: Bool = false
        var gestureBegin: Bool = false
    var storedAnnotations:[LocationPin] = []
    var navigationBarColor:UIColor!
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Edit Button
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationBarColor = self.navigationController?.navigationBar.barTintColor

        let stack = getCoreDataStack()
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "LocationPin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Load Data
        self.loadAnnotationsFromCoreData()
        // Update the annotations
        self.updateAllAnnotation()
    }
    
    /**
     Gets Core Data Stacks.
     */
    func getCoreDataStack() -> CoreDataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    /**
     Adds Annotation to Core Data Stacks.
     */
    func addAnnotationToCoreData(annotation: MKAnnotation) {
        do {
            let coordinate = annotation.coordinate
            let pin = LocationPin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: getCoreDataStack().context)
            try getCoreDataStack().saveContext()
            storedAnnotations.append(pin)
        } catch {
            print("Add Core Data Failed")
        }
    }
    
    /**
     Deletes Annotation to Core Data Stacks.
     */
    func deleteAnnotationFromCoreData(annotation: MKAnnotation) {
        
        let coordinate = annotation.coordinate
        for pin:LocationPin in storedAnnotations {
            if pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude {
                do {
                    getCoreDataStack().context.delete(pin)
                    try getCoreDataStack().saveContext()
                } catch {
                    print("Remove Core Data Failed")
                }
                break
            }
        }
    }
    
    /**
     Loads all the annotations from Core Data.
     */
    private func loadAnnotationsFromCoreData() {
        do {
            try fetchedResultsController.performFetch()
            let counter = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            for index in 0 ..< counter {
                let locationPin = fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! LocationPin
                self.storedAnnotations.append(locationPin)
            }
        } catch {
            print("Error Fetching Data")
        }
    }
    
    /**
     Updates all the annotations in the Map View.
     */
    private func updateAllAnnotation() {
        for pin:LocationPin in storedAnnotations {
            
            let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            addAnnotationToMap(fromCoordinate: coordinate)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            createAndShowAlert("Edit Mode", "Click on the Pins to delete them", "OK")
            self.navigationController?.navigationBar.barTintColor = UIColor(red: 196/255, green: 155/255, blue: 143/255, alpha: 0.3)
        } else {
            self.navigationController?.navigationBar.barTintColor = navigationBarColor
        }
        editMode = editing
    }
}

// MARK: - TravelLocationsMapViewController: MKMapViewDelegate

extension TravelLocationsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if (!editMode) {
            
            // Go to Photo album of the clicked annotation
            performSegue(withIdentifier: "PinPhotos", sender: view.annotation?.coordinate)
            mapView.deselectAnnotation(view.annotation, animated: false)
            
        } else {
            
            // Remove annotation from core data
            deleteAnnotationFromCoreData(annotation: view.annotation!)
            // Remove annotation from map
            mapView.removeAnnotation(view.annotation!)
        }
    }
    
    /**
     Prepare for Segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PinPhotos" {
            
            let destination = segue.destination as! PhotoAlbumViewController
            let coordinate = sender as! CLLocationCoordinate2D
            destination.coordinateSelected = coordinate
            
            for pin:LocationPin in storedAnnotations {
                
                if pin.latitude == coordinate.latitude && pin.longitude == coordinate.longitude {
                    
                    destination.coreDataLocationPin = pin
                    break
                }
            }
            
        }
    }
    
    /**
     Creates and shows simple.
     */
    func createAndShowAlert(_ title: String, _ message: String, _ acction: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acction, style: .default) { _ in })
        self.present(alert, animated: true){}
    }
}

// MARK: - TravelLocationsMapViewController: UIGestureRecognizerDelegate

extension TravelLocationsMapViewController: UIGestureRecognizerDelegate {
    
    // MARK: Actions
    
    @IBAction func responseLongTapAction(_ sender: Any) {
        
        if gestureBegin {
            let gestureRecognizer = sender as! UILongPressGestureRecognizer
            let gestureTouchLocation = gestureRecognizer.location(in: mapView)
            addAnnotationToMap(fromPoint: gestureTouchLocation)
            gestureBegin = false
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureBegin = true
        return true
    }
    
    func addAnnotationToMap(fromPoint: CGPoint) {
        
        let coordToAdd = mapView.convert(fromPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordToAdd
        addAnnotationToCoreData(annotation: annotation)
        mapView.addAnnotation(annotation)
        
    }
    
    func addAnnotationToMap(fromCoordinate: CLLocationCoordinate2D) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = fromCoordinate
        mapView.addAnnotation(annotation)
    }
}

