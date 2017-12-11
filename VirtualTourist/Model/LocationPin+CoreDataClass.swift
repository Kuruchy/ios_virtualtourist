//
//  LocationPin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 06.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//
//

import Foundation
import CoreData

@objc(LocationPin)
public class LocationPin: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(latitude: Double = 0, longitude: Double = 0, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "LocationPin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
