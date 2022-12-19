//
//  DeviceDetailView.swift
//  coop
//
//  Created by Ryan Romanchuk on 12/16/22.
//

import SwiftUI
import NetvueSDK
import RealmSwift
import Combine


struct LivePlayerUIKit: UIViewControllerRepresentable {
    @Binding var deviceNode: DeviceNode?
    
    func makeUIViewController(context: Context) -> LiveDeviceViewController {
        let vc = UIStoryboard(name: "Devices", bundle: nil).instantiateViewController(withIdentifier: "LiveDeviceViewController") as! LiveDeviceViewController
        
        vc.deviceNode = deviceNode
        return vc
    }

    func updateUIViewController(_ uiViewController: LiveDeviceViewController, context: Context) {
        uiViewController.deviceNode = deviceNode
    }
}


struct DeviceDetailView: View {
    enum CameraControl {
        case start
        case stop
        case siren
        case mute
    }
    
    @ObservedRealmObject var device: CameraDevice
    @State var liveView = false
    @State var deviceNode: DeviceNode?
    @State var playerState: MediaPlayerState = MediaPlayerState.idle
    
    static let CameraControlEvent = PassthroughSubject<CameraControl, Never>()
    static let CameraStateEvent = PassthroughSubject<MediaPlayerState, Never>()
    
    var body: some View {
        VStack(spacing: 20) {
            
            switch device.batteryPercent {
            case 0:
                Label("\(device.batteryPercent)", systemImage: "battery.0")
            case 0..<25:
                Label("\(device.batteryPercent)", systemImage: "battery.50")
            case 25..<50:
                Label("\(device.batteryPercent)", systemImage: "battery.25")
            case 50..<75:
                Label("\(device.batteryPercent)", systemImage: "battery.75")
            default:
                Label("\(device.batteryPercent)", systemImage: "battery.100")
            
            }
            HStack {
                Text("Serial Number:")
                Text(device.serialNumber)
            }
            
            HStack {
                Text("Model Name")
                Text(device.modelName)
            }
            
            HStack {
                Text("Friendly Name:")
                Text(device.name)
            }
            
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
            
            HStack {
                Text("LAN IP:")
                Text(device.ipAddress)
            }
            
            
            
            
            LivePlayerUIKit(deviceNode: $deviceNode)
                .frame(height: 250)
           
            if playerState == MediaPlayerState.idle {
                Button("Play") {
                    DeviceDetailView.CameraControlEvent.send(CameraControl.start)
                }
            } else {
                Button("Stop") {
                    DeviceDetailView.CameraControlEvent.send(CameraControl.stop)
                }
            }
        }
        .padding()
        .navigationTitle(device.name)
        .onAppear {
            DispatchQueue.main.async {
                NetvueManager.shared.fetchDevice(device.serialNumber) { dn in
                    guard let dn else {
                        log.error("Could not fetch deviceNode")
                        return
                    }
                    deviceNode = dn
                }
            }
        }
        .onReceive(DeviceDetailView.CameraStateEvent) { state in
            playerState = state
        }
    }
    
    
}

//struct DeviceDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DeviceDetailView()
//    }
//}
