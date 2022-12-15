//
//  CameraDevice.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import RealmSwift


class CameraDevice: Object, Identifiable {
    @Persisted(primaryKey: true) public var serialNumber = ""
    @Persisted public var online = false
    @Persisted public var name = "Unkown"
    @Persisted public var ipAddress = "Unkown"
    @Persisted public var batteryPercent = 0
    
    var id: String {
        serialNumber
    }
}
