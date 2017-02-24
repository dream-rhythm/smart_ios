//
//  Settings+CoreDataProperties.swift
//  smart_ios
//
//  Created by 吳懿修 on 2017/2/19.
//  Copyright © 2017年 WaterMoon. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Settings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Settings> {
        return NSFetchRequest<Settings>(entityName: "Settings");
    }

    @NSManaged public var serverIP: String?

}
