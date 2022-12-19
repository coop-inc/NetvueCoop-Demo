//
//  CameraDevice.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import RealmSwift


public class CameraDevice: Object, Identifiable {
    @Persisted(primaryKey: true) public var serialNumber = ""
    @Persisted public var online = false
    @Persisted public var name = "Unkown"
    @Persisted public var modelName = "Unkown"
    @Persisted public var ipAddress = "Unkown"
    @Persisted public var batteryPercent = 0
    
    public var id: String {
        serialNumber
    }
}
