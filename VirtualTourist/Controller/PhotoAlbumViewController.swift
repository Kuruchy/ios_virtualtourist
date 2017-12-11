//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 07.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: Variables
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    var coordinateSelected:CLLocationCoordinate2D!
    var coreDataLocationPin:LocationPin!
    
    var newCollectionBarButton:UIBarButtonItem!
    var deleteImagesBarButton:UIBarButtonItem!
    
    var savedImages:[Photo] = []
    
    var photoIndexesSelectedToDelete:[Int] = [] {
        didSet {
            if photoIndexesSelectedToDelete.count > 0 {
                self.navigationItem.rightBarButtonItem? = deleteImagesBarButton
                self.title = "Remove selected images"
            } else {
                self.navigationItem.rightBarButtonItem? = newCollectionBarButton
                self.title = ""
            }
        }
    }
    
    let spacingBetweenItems:CGFloat = 3
    let maxImagesShown:Int = 21

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var noPhotosLabel: UILabel!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // New Collection Button
        newCollectionBarButton = UIBarButtonItem(image: UIImage(named: "icon_add"), style: .plain, target: self, action: #selector(PhotoAlbumViewController.onNewCollectionPressed))
        deleteImagesBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.trash, target: self, action: #selector(PhotoAlbumViewController.onDeletePressed))
        
        self.navigationItem.rightBarButtonItem  = newCollectionBarButton
        
        let stack = getCoreDataStack()
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "locationPins = %@", argumentArray: [coreDataLocationPin!])
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        setUpCollectionViewFlowLayout()

        //Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        //Add To Map
        addAnnotationToMap()
        
        //Fetch Photos
        let savedPhotos = loadPhotosFromCoreData()
        
        if savedPhotos != nil && savedPhotos?.count != 0 {
            savedImages = savedPhotos!
            showSavedCollection()
            
        } else {
            createNewCollection()
        }
        
        // No Photos Label
        self.noPhotosLabel.isHidden = true
    }
    
    /**
     Shows saved Collection.
     */
    private func showSavedCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    /**
     Deletes old Collection and Creates new one.
     */
    private func createNewCollection() {
        
        // Don't allow to modify until the new collection is downloaded
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.deleteAllPhotosFromCoreData()
        self.savedImages.removeAll()
        self.collectionView.reloadData()
        
        getRandomImagesFromFlickr { (flickrImages) in
            
            if flickrImages != nil {
                DispatchQueue.main.async {
                    self.savePhotosToCoreData(flickrImages: flickrImages!, coreDataPin: self.coreDataLocationPin)
                    self.savedImages = self.loadPhotosFromCoreData()!
                    self.showSavedCollection()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.noPhotosLabel.isHidden = false
                }
            }
        }
    }
    
    /**
     Button New Collection Action.
     */
    @objc private func onNewCollectionPressed() {
        if photoIndexesSelectedToDelete.count == 0 {
            createNewCollection()
        }
    }
    
    /**
     Button Delete Action.
     */
    @objc private func onDeletePressed() {
        if photoIndexesSelectedToDelete.count > 0 {
            deletePhotoSelectedToDeleteFromCoreData()
            unselectAllSelectedViewCells()
            self.savedImages = self.loadPhotosFromCoreData()!
            showSavedCollection()
        }
    }
    
    /**
     Sets up the Collection View Flow Layout.
     */
    private func setUpCollectionViewFlowLayout() {
        let space: CGFloat = 3.0
        let dimension = (self.view.frame.size.width - (2 * space)) / 3.0
        
        collectionViewFlowLayout.minimumInteritemSpacing = spacingBetweenItems
        collectionViewFlowLayout.minimumLineSpacing = spacingBetweenItems
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    /**
     Gets Core Data Stacks.
     */
    private func getCoreDataStack() -> CoreDataStack {
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    /**
     Saves all the Photos to Core Data.
     */
    private func savePhotosToCoreData(flickrImages:[FlickrImage], coreDataPin:LocationPin) {
        
        for image in flickrImages {
            do {
                let delegate = UIApplication.shared.delegate as! AppDelegate
                let stack = delegate.stack
                let photo = Photo(index: flickrImages.index{$0 === image}!, url: image.imageURL(), imageData: nil, context: stack.context)
                photo.locationPins = coreDataPin
                try stack.saveContext()
            } catch {
                print("Save to Core Data Failed")
            }
        }
    }
    
    /**
     Deletes all the Photos from Core Data.
     */
    private func deleteAllPhotosFromCoreData() {
        
        for photo:Photo in savedImages {
            
            getCoreDataStack().context.delete(photo)
        }
    }
    
    /**
     Deletes only the Photos from Core Data that are selected to delete.
     */
    func deletePhotoSelectedToDeleteFromCoreData() {
        
        for index in 0..<savedImages.count {
            
            if photoIndexesSelectedToDelete.contains(index) {
                
                getCoreDataStack().context.delete(savedImages[index])
            }
        }
        
        do {
            try getCoreDataStack().saveContext()
            
        } catch {
            
            print("Remove Core Data Photo Failed")
        }
        
        photoIndexesSelectedToDelete.removeAll()
    }
    
    /**
     Loads all the Photos from Core Data.
     */
    private func loadPhotosFromCoreData() -> [Photo]? {
        do {
            var photoArray:[Photo] = []
            try fetchedResultsController.performFetch()
            let counter = try fetchedResultsController.managedObjectContext.count(for: fetchedResultsController.fetchRequest)
            
            for index in 0 ..< counter {
                let photo = fetchedResultsController.object(at: IndexPath(row: index, section: 0)) as! Photo
                photoArray.append(photo)
            }
            return photoArray.sorted(by: {$0.index < $1.index})
        } catch {
            print("Error Fetching Data")
            return nil
        }
    }
    
    /**
     Gets random images from Flickr.
     */
    private func getRandomImagesFromFlickr(completion: @escaping (_ result:[FlickrImage]?) -> Void) {
        
        var imageArray:[FlickrImage] = []
        FlickrClient.getFlickrImages(lat: coordinateSelected.latitude, lng: coordinateSelected.longitude) { (success, flickrImages) in
            if success {
                if flickrImages!.count > self.maxImagesShown {
                    var randomArray:[Int] = []
                    while randomArray.count < self.maxImagesShown {
                        let random = arc4random_uniform(UInt32(flickrImages!.count))
                        if !randomArray.contains(Int(random)) { randomArray.append(Int(random)) }
                    }
                    for random in randomArray {
                        imageArray.append(flickrImages![random])
                    }
                    completion(imageArray)
                } else {
                    completion(flickrImages!)
                }
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - PhotoAlbumViewController: MKMapViewDelegate

extension PhotoAlbumViewController: MKMapViewDelegate {
    private func addAnnotationToMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinateSelected
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
}

// MARK: - PhotoAlbumViewController: UICollectionViewDelegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        cell.initWithPhoto(savedImages[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - spacingBetweenItems
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return spacingBetweenItems
    }
    
    /**
     Sends an array of index to the DeleteArray
     */
    private func selectToDelete(_ indexPathArray: [IndexPath]) {
        var selectedArray:[Int] = []
        for indexPath in indexPathArray {
            selectedArray.append(indexPath.row)
        }
        photoIndexesSelectedToDelete = selectedArray
    }
    
    /**
     Unselects "changing alpha" all the selected images
     */
    private func unselectAllSelectedViewCells() {
        for indexPath in collectionView.indexPathsForSelectedItems! {
            collectionView.deselectItem(at: indexPath, animated: false)
            collectionView.cellForItem(at: indexPath)?.contentView.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectToDelete(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.5
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        selectToDelete(collectionView.indexPathsForSelectedItems!)
        let cell = collectionView.cellForItem(at: indexPath)
        
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1
        }
    }
}
