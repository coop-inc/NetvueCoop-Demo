//
//  NetvueCoopDemoApp.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import SwiftyBeaver
let log = SwiftyBeaver.self
let console = ConsoleDestination()

@main
struct NetvueCoopDemoApp: App {
    
    init() {
        log.addDestination(console)
        RealmManager.configure()
        NetvueManager.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

