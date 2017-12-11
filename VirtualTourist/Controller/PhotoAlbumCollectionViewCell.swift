//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 07.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    func initWithPhoto(_ photo: Photo) {
        if photo.imageData != nil {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: photo.imageData! as Data)
            }
        } else {
            downloadImage(photo)
        }
    }
    
    /**
     Downloads the Image
     */
    func downloadImage(_ photo: Photo) {
        
        URLSession.shared.dataTask(with: photo.url!) { (data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data! as Data)
                    self.saveImageDataToCoreData(photo: photo, imageData: data! as NSData)
                }
            } else {
                print(error.debugDescription)
            }
        }
        .resume()
    }
    
    /**
     Saves Image to Core Data
     */
    func saveImageDataToCoreData(photo: Photo, imageData: NSData) {
        do {
            photo.imageData = imageData
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            try stack.saveContext()
        } catch {
            print("Saving Photo imageData Failed")
        }
    }
}
