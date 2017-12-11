//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 05.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation

// MARK: - FlickrClient: NSObject

class FlickrClient : NSObject {
    
    // MARK: Get Flickr Imagess
    
    static func getFlickrImages(lat: Double, lng: Double, completion: @escaping (_ success: Bool, _ flickrImages:[FlickrImage]?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string:
            "\(Constants.ApiURL)" +
            "?method=\(Methods.Search)" +
            "&format=\(Constants.Format)" +
            "&api_key=\(Constants.ApiKey)" +
            "&lat=\(lat)" +
            "&lon=\(lng)" +
            "&radius=\(Constants.RadiusSearch)")!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            if error != nil {
                
                completion(false, nil)
                return
            }
            
            let range = Range(uncheckedBounds: (14, data!.count - 1))
            let newData = data?.subdata(in: range)
            
            if let json = try? JSONSerialization.jsonObject(with: newData!) as? [String:Any],
                let photosMeta = json?["photos"] as? [String:Any],
                let photos = photosMeta["photo"] as? [Any] {
                
                var flickrImages:[FlickrImage] = []
                
                for photo in photos {
                    
                    if let flickrImage = photo as? [String:Any],
                        let id = flickrImage["id"] as? String,
                        let secret = flickrImage["secret"] as? String,
                        let server = flickrImage["server"] as? String,
                        let farm = flickrImage["farm"] as? Int {
                        flickrImages.append(FlickrImage(id: id, secret: secret, server: server, farm: farm))
                    }
                }
                
                completion(true, flickrImages)
                
            } else {
                
                completion(false, nil)
            }
        }
        
        task.resume()
    }
}
