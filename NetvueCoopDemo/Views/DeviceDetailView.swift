//
//  DeviceDetailView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import RealmSwift

struct DeviceDetailView: View {
    @ObservedRealmObject var device: CameraDevice
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Serial Number: \(device.serialNumber)")
            Text("Friendly Name: \(device.name)")
            HStack {
                Text("Status: ")
                if device.online {
                    Text("Online")
                        .foregroundColor(.green)
                } else {
                    Text("Offline")
                        .foregroundColor(.red)
                }
            }
            Text("IP: \(device.ipAddress)")
        }
        .padding()
        .navigationTitle(device.name)
    }
}

struct DeviceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceDetailView(device: CameraDevice())
    }
}
