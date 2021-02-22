//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

@objc public enum SimDeviceState: Int {
    case creating
    case shutdown
    case booting
    case booted
    case shuttingDown
}

@objc protocol SimDeviceRuntimeProtocol: NSObjectProtocol {
    var versionString: String? { get }
}

@objc protocol SimDeviceProtocol: NSObjectProtocol {
    var UDID: UUID { get set }
    var name: String { get }
    var runtime: SimDeviceRuntimeProtocol? { get set }
    var state: SimDeviceState { get set }
    
    func sendPushNotification(forBundleID bundleID: String, jsonPayload json: [AnyHashable : Any]) throws
}

@objc protocol SimDeviceSetProtocol: NSObjectProtocol {
    var devices: [AnyObject] { get }
    
    func registerNotificationHandler(_ handler: @escaping ([AnyHashable: Any]) -> Void) -> UInt64
}

@objc protocol SimServiceContextProtocol: NSObjectProtocol {
    static func sharedServiceContext(forDeveloperDir developerDirectory: String, error: NSErrorPointer) -> Self
    
    func defaultDeviceSetWithError(_ error: NSErrorPointer) -> SimDeviceSetProtocol
}
