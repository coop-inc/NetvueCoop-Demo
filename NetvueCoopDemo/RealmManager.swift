//
//  RealmManager.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import Foundation
import RealmSwift
import os.log

public struct RealmManager {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: RealmManager.self)
    )
    
    public static func configure() {
        var config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { _, _ in
                // nothing needed so far
            },
            deleteRealmIfMigrationNeeded: true
        )
        
        config.shouldCompactOnLaunch = { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file
            
            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneHundredMB = 100 * 1024 * 1024
            return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.5
        }
        
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("NetvueCoopDemo").appendingPathExtension("realm")
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}
