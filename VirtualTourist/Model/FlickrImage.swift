//
//  FlickrImage.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 05.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrImage {
    
    let id:String
    let secret:String
    let server:String
    let farm:Int
    
    init(id: String, secret: String, server: String, farm: Int) {
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
    }
    
    func imageURL() -> URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!
    }
    
}
