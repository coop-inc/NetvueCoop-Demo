//
//  DeviceDetailView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import RealmSwift

struct DeviceDetailView: View {
    enum ActiveSheet {
        case live
    }
    @ObservedRealmObject var device: CameraDevice
    @State private var path: [ContentView.Path] = []
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
            
            Button(action: {
                NetvueManager.shared.fetchDevice(device.serialNumber) { device in
                    if let device {
                        path.append(ContentView.Path.live(device: device))
                    }
                }
            }, label: {
                Text("View Live Stream")
            })
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
