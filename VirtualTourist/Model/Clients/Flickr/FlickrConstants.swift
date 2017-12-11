//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 05.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation

// MARK: - FlickrConstants

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        static let ApiURL = "https://api.flickr.com/services/rest/"
        static let ApiKey = "2a2ad0534c538cea62c640e0d2520400"
        static let Format = "json"
        static let RadiusSearch = 10
    }
    
    // MARK: Methods
    struct Methods {
        static let Search = "flickr.photos.search"
    }
}
