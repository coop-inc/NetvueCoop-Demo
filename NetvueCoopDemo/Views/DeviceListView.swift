//
//  DeviceListView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import RealmSwift

struct DeviceListView: View {
    @ObservedResults(CameraDevice.self) var devices
    @State private var selectedDevice: CameraDevice?
    
    var body: some View {
        List(devices) { device in
            NavigationLink(value: ContentView.Path.device_details(device: device)) {
                DeviceRowView(device: device)
            }
        }
        .navigationTitle("Your Devices")
        .onAppear {
            DispatchQueue.main.async {
                NetvueManager.shared.fetchDevices()
            }
        }
    }
}

struct DeviceListView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceListView()
    }
}
