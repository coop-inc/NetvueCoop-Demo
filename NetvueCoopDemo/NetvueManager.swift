//
//  NetvueManager.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import Foundation
import os.log
import RealmSwift

// There is no arm64 build for simulator. Protect the IDE from exploding by faking
// `NetvueManager` with a stub class
#if IOS_SIMULATOR
class NetvueManager {
    static let shared = NetvueManager()
}
extension NetvueManager {
    static func start() {}
    func fetchDevice() {}
    func fetchDevices() {}
    func login() {}
}
#else
import NetvueSDK

class NetvueManager: UserManagerNotifications, MediaPlayerDelegate {
    func onMediaPlayerError(mediaPlayer: MediaPlayer, error: MediaPlayerError) {
        
    }
    
    func onMediaPlayerReportNetworkSpeed(mediaPlayer: MediaPlayer, byteSizePerSecond: Int64) {
        
    }
    
    func onMediaPlayerStateChanged(mediaPlayer: MediaPlayer, state: MediaPlayerState) {
        
    }
    
    func onMediaPlayerVideoRendered(pts: Int64) {
        
    }
    
    static let shared = NetvueManager()
    private let RealmBackgroundQueue = DispatchQueue(label: "farm.coop.NetvueCoopDemo", qos: .utility, autoreleaseFrequency: .workItem, target: .main)
    
    private let consoleLogger = ConsoleLogger(enabledPriority: LogLevel.verbose)
    private init() {
        NetvueSDK.init().userManager.registerNotifications(delegate: self)
        SDKLog.init().addLogger(logger: consoleLogger)
    }
    
    static func start() {
        Self.logger.info("NetvueSDK starting....")
        NetvueSDK.init().configure { conf in
            Self.logger.info("Configuring....")
            conf.enableLifeCycleListener = true
            conf.ucid = "82db69b981"
            conf.appName = "Coop"
        }
    }
    

    lazy var sdkVersion: String = {
        NetvueSDK.init().description()
    }()
    
    lazy var phoneUDID: String = {
        SystemEnv.init().deviceUDID()
    }()
    
    var isLoggedIn: Bool {
        NetvueSDK.init().userManager.isLoggedIn()
    }
    
    func fetchDevice(_ serialNumber: String) {
        
        DeviceManager.init().getDevice(serialNumber: serialNumber, refreshList: false) { deviceNode, error in
            
        }
    }

    
    /// Fetch devices updating our own friendlier wrapper `CameraDevice`
    func fetchDevices() {
        
        DeviceManager.init().getDeviceList(forceRefresh: false) { devices, error in

            devices?.forEach { deviceNode in
                Self.logger.info("device: \(deviceNode.serialNumber, privacy: .public)")
                self.updateDevice(deviceNode)
  
            }
        }
    }
    
//    private func updateDevice(_ device: DeviceNode) async {
//        do {
//            let online = try await device.online.getValue() as Any
//            let name = try await device.name.getValue() as Any
//            let ipAddress = try await device.wifiIp.getValue() as Any
//            let batteryPercent = try await device.batteryPercent.getValue() as Any
//            let sn = device.serialNumber
//
//
//            RealmBackgroundQueue.async { [self] in
//                let realm = try! Realm(configuration: .defaultConfiguration, queue: RealmBackgroundQueue)
//                realm.beginWrite()
//                let object = realm.create(CameraDevice.self, value: ["serialNumber": sn, "name": name, "online": online, "ipAddress": ipAddress, "batteryPercent": batteryPercent ] , update: .modified)
//                try! realm.commitWrite()
//            }
//
//        } catch {
//            Self.logger.error("updateDevice failed: \(error.localizedDescription, privacy: .public)")
//        }
//
//    }
    
    private func updateDevice(_ device: DeviceNode) {
        //DeviceExpressInstruction(instruction: "Test")
        //NetvueSDK.init().httpAPI.devices.
        device.online.getValue { val, error in
            if let val {
                Self.logger.debug("deviceNode.online.getValue: \(val.boolValue, privacy: .public)")
                let realm = try! Realm()
                try! realm.write {
                    realm.create(CameraDevice.self, value: ["serialNumber": device.serialNumber, "online": val.boolValue], update: .modified)
                }
            }
            if let error {
                Self.logger.error("error: \(error, privacy: .public)")
            }
        }
        
        device.name.getValue { val, error in
            if let val {
                Self.logger.info("deviceNode.name.getValue: \(val, privacy: .public)")
                let realm = try! Realm()
                try! realm.write {
                    realm.create(CameraDevice.self, value: ["serialNumber": device.serialNumber, "name": val], update: .modified)
                }
            }
        }
        
        device.wifiIp.getValue { val, error in
            if let val {
                Self.logger.info("device.wifiIp.getValue: \(val, privacy: .public)")
                let realm = try! Realm()
                try! realm.write {
                    realm.create(CameraDevice.self, value: ["serialNumber": device.serialNumber, "ipAddress": val], update: .modified)
                }
            }
        }
        
        device.batteryPercent.getValue { val, error in
            if let val {
                Self.logger.info("device.batteryPercent.getValue: \(val, privacy: .public)")
                let realm = try! Realm()
                try! realm.write {
                    realm.create(CameraDevice.self, value: ["serialNumber": device.serialNumber, "batteryPercent": val], update: .modified)
                }
            }
        }
    }
    
    func login(username: String, password: String) {
        guard !NetvueSDK.init().userManager.isLoggedIn() else {
            Self.logger.info("User already logged in")
            //setUserInfo()
            return
        }
        
        NetvueSDK.init().userManager.login(username: username, password: password, locale: NSLocale.current.identifier) { retCode, error in
            DispatchQueue.main.async {
                if let error {
                    Self.logger.error("error: \(error, privacy: .public)")
                }
                
                if let retCode {
                    switch retCode.int32Value {
                    case NetvueReturnCode.ok.value:
                        Self.logger.info("OK")
                    case NetvueReturnCode.userpwdnotmatch.value:
                        Self.logger.error("Incorrect username or password")
                    default:
                        Self.logger.error("retCode: \(Int(retCode.intValue)) error: \(String(describing: error))")
                    }
                }
            }
        }
    }
}


// MARK: UserManagerNotifications
extension NetvueManager {
    func onUserLogin() {
        DispatchQueue.main.async {
            Self.logger.info("onUserLogin")
        }
    }
    
    func onUserLogout(reason: UserLogoutReason) {
        DispatchQueue.main.async {
            Self.logger.info("onUserLogout reason: \(reason, privacy: .public)")
        }
    }
}



// MARK: Logger
extension NetvueManager {
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: "NetvueManager")
    )
}

#endif




