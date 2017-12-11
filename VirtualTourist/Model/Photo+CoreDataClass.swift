//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 07.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    // MARK: Initializer
    
    convenience init(index:Int, url: URL, imageData: NSData?, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.index = Int16(index)
            self.url = url
            self.imageData = imageData
        } else {
            fatalError("Unable To Find Entity Name!")
        }
    }
}
