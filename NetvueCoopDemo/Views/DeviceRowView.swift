//
//  DeviceRowView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import RealmSwift

struct DeviceRowView: View {
    @ObservedRealmObject var device: CameraDevice
    var body: some View {
        HStack {
            VStack {
                Text(device.name)
                    .font(.callout)
                Text(device.id)
                    .font(.caption2)
            }
            Spacer()
            Text("\(device.batteryPercent)%")
            if device.online {
                Text("Online")
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            } else {
                Text("Offline")
                    .fontWeight(.medium)
                    .foregroundColor(.red)
            }
        }
    }
}

struct DeviceRowView_Previews: PreviewProvider {
    static var previews: some View {
        
        DeviceRowView(device: CameraDevice())
    }
}
