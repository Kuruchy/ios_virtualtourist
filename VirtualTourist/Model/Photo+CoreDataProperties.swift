//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Bruno Retolaza on 07.12.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var index: Int16
    @NSManaged public var url: URL?
    @NSManaged public var imageData: NSData?
    @NSManaged public var locationPins: LocationPin?

}
