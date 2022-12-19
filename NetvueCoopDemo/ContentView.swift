//
//  ContentView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import SwiftUI
import NetvueSDK

struct ContentView: View {
    
    enum Path: Hashable {
        case device_list
        case device_details(device: CameraDevice)
    }
    
    @State private var presentedViews: [Path] = []
    var body: some View {
        NavigationStack(path: $presentedViews) {
            VStack(spacing: 15) {
                HStack {
                    Text("NetvueSDK Version")
                    Spacer()
                    Text(NetvueManager.shared.sdkVersion)
                        .font(.caption)
                }
                
                HStack {
                    Text("SDK phone UDID")
                    Spacer()
                    Text(NetvueManager.shared.phoneUDID)
                        .font(.caption)
                }
                
                HStack {
                    Text("Logged in?")
                    Spacer()
                    if NetvueManager.shared.isLoggedIn {
                        Text("YES")
                            .foregroundColor(.green)
                            
                    } else {
                        Text("NO")
                            .foregroundColor(.red)
                    }
                    
                }
                
                
                NavigationLink(value: Path.device_list) {
                    Text("View Devices")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationDestination(for: Path.self) { path in
                switch path {
                case .device_list:
                    DeviceListView()
                case let .device_details(device):
                    DeviceDetailView(device: device)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    NetvueManager.shared.login(username: Config.username, password: Config.password)
                }
            }
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
