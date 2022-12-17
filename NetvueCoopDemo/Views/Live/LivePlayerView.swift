//
//  LivePlayerView.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/16/22.
//

import SwiftUI
import NetvueSDK
struct LivePlayerView: View {
    @State var device: DeviceNode?
    var body: some View {
        VStack {
            if let device {
                LivePlayer(device: device)
            }
        }
    }
}

struct LivePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        LivePlayerView()
    }
}
