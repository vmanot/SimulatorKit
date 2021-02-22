//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Filesystem
import Merge
import POSIX
import Swallow

/// A struct representing a simulator device.
public struct SimulatorDevice: Identifiable, Hashable {
    public typealias State = SimDeviceState
    
    /// A unique, persistent identifier that can be used to identify this device.
    public let id: UUID
    /// The name of the device.
    public let name: String
    /// The runtime version of this device.
    public let runtimeVersion: String?
    /// The state of the device.
    public let state: State
    
    private init(device: SimDeviceProtocol) {
        self.id = device.UDID
        self.name = device.name
        self.runtimeVersion = device.runtime?.versionString
        self.state = device.state
    }
}

extension SimulatorDevice {
    /// Get a list of all available simulator devices.
    public static func all() throws -> [Self] {
        if handle == nil {
            handle = try POSIXDynamicLibraryHandle.open(at: "/Library/Developer/PrivateFrameworks/CoreSimulator.framework/CoreSimulator")
        }
        
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/xcode-select"), arguments: ["-p"])
        
        let output = task.standardOutputAndErrorLinesPublisher
            .tryMap({ try $0.leftValue.unwrap() })
            .timeout(5.0, scheduler: DispatchQueue.global(qos: .userInitiated))
            .first()
            .subscribeAndWaitUntilDone()
        
        return unsafeBitCast(NSClassFromString("SimServiceContext"), to: SimServiceContextProtocol.Type.self)
            .sharedServiceContext(forDeveloperDir: try output.get(), error: nil)
            .defaultDeviceSetWithError(nil)
            .devices
            .map({ SimulatorDevice(device: unsafeBitCast($0, to: SimDeviceProtocol.self)) })
    }
    
    private static var handle: POSIXDynamicLibraryHandle?
}

extension SimulatorDevice {
    /// Boots up the simulator, if not booted already.
    public func boot() throws {
        guard state != .booted else {
            return
        }
        
        let task = Process.Task(
            executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "boot", id.uuidString]
        )
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    /// Bring this simulator device into the foreground.
    ///
    /// This launches the iOS Simulator app that is bundled with the Xcode with this simulator device as the active device.
    public func foreground() throws {
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/open"), arguments: ["-a", "Simulator", "--args", "-CurrentDeviceUDID", id.uuidString])
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    /// Copy and install an ".app" from a given location.
    public func installApp(from url: URL) throws {
        let task = Process.Task(
            executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "install", id.uuidString, url.path]
        )
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    /// Screenshot this simulator device.
    ///
    /// Note: The screenshot is taken immediately, which may be undesirable if called right after an app is launched via `Simulator/launchApp(withIdentifier:)` because it would capture the home screen -> app animation rather than a screenshot of the app fully launched and loaded.
    public func screenshot() throws -> Data {
        let temporaryDirectoryPath = FilePath.temporaryDirectory()
        let temporaryFilePath = temporaryDirectoryPath + "screenshot.jpg"
        
        let task = Process.Task(
            executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "io", id.uuidString, "screenshot", temporaryDirectoryPath.stringValue]
        )
        
        task.start()
        
        try task.waitUntilExit()
        
        let data = try Data(contentsOf: URL(temporaryFilePath).unwrap())
        
        try FileManager.default.removeItem(at: temporaryFilePath)
        
        return data
    }
    
    /// Launches an installed app, identified by the given app identifier.
    public func launchApp(withIdentifier appIdentifier: String)  throws{
        let task = Process.Task(
            executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "launch", id.uuidString, appIdentifier]
        )
        
        task.start()
        
        try task.waitUntilExit()
    }
}

// MARK: - Conformances -

extension SimulatorDevice {
    public var description: String {
        guard let runtimeVersion = runtimeVersion else {
            return name
        }
        
        return "\(name) (\(runtimeVersion))"
    }
}

#endif
