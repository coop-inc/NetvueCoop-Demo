//
//  NetvueManager.swift
//  NetvueCoopDemo
//
//  Created by Ryan Romanchuk on 12/13/22.
//

import Foundation
import os.log
import RealmSwift
import NetvueSDK

class NetvueManager: UserManagerNotifications {

    
    static let shared = NetvueManager()
    var userInfo: UserInfo?
    private let consoleLogger = ConsoleLogger(enabledPriority: LogLevel.verbose)
    
    lazy var sdkVersion: String = {
        NetvueSDK.init().description()
    }()
    
    lazy var phoneUDID: String = {
        SystemEnv.init().deviceUDID()
    }()
    
    var isLoggedIn: Bool {
        NetvueSDK.init().userManager.isLoggedIn()
    }
    
    var username: String? {
        userInfo?.userName
    }
    
    func setUserInfo() {
        userInfo = NetvueSDK.init().userManager.userInfoManager.takeUserInfo()
    }
        
    private init() {
        NetvueSDK.init().userManager.registerNotifications(delegate: self)
        //SDKLog.init().addLogger(logger: consoleLogger)
    }
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: "NetvueManager")
    )
    
    static func start() {
        Self.logger.info("NetvueSDK starting....")
        NetvueSDK.init().configure { conf in
            Self.logger.info("Configuring....")
            conf.enableLifeCycleListener = true
            conf.ucid = "82db69b981"
            conf.appName = "Coop"
        }
        
    }
    

    func fetchDevice(_ serialNumber: String, completion: @escaping (DeviceNode?) -> Void)  {
        Self.logger.info("Fetching device \(serialNumber, privacy: .public)")
        DeviceManager.init().getDevice(serialNumber: serialNumber, refreshList: false) {  deviceNode, error in
            Self.logger.info("Retruning \(deviceNode, privacy: .public)")
            DispatchQueue.main.async {
                completion(deviceNode)
            }
        }
    }
    
    func fetchDevices() {
        DeviceManager.init().getDeviceList(forceRefresh: false) { devices, error in
            devices?.forEach { deviceNode in
                Self.logger.info("device: \(deviceNode.serialNumber, privacy: .public)")
                self.updateDevice(deviceNode)
            }
        }
    }
    
    private func updateDevice(_ device: DeviceNode) {
        device.online.getValue { val, error in
            if let val {
                Self.logger.debug("deviceNode.online.getValue: \(val.boolValue, privacy: .public)")
                let realm = try! Realm()
                try! realm.write {
                    realm.create(CameraDevice.self, value: ["serialNumber": device.serialNumber, "online": val.boolValue, "modelName": device.modelName.name], update: .modified)
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
            setUserInfo()
            return
        }
        
        NetvueSDK.init().userManager.login(username: "d7b255b59a9d4642", password: "runhir-zetru5-bYnvyt", locale: NSLocale.current.identifier) { retCode, error in
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
            Self.logger.info("reason: \(reason, privacy: .public)")
        }
    }
}


