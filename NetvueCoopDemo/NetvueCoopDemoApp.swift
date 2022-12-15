//
//  NetvueCoopDemoApp.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI


@main
struct NetvueCoopDemoApp: App {
    
    init() {
        RealmManager.configure()
        NetvueManager.start()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

