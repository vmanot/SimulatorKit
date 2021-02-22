//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import Filesystem
import FoundationX
import Merge
import Runtime
import Swift

public struct SimulatorDevice: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let runtimeVersion: String?
    public let state: SimDeviceState
    
    init(device: SimDeviceProtocol) {
        self.id = device.UDID
        self.name = device.name
        self.runtimeVersion = device.runtime?.versionString
        self.state = device.state
    }
}

extension SimulatorDevice {
    public func foreground() throws {
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/open"), arguments: ["-a", "Simulator", "--args", "-CurrentDeviceUDID", id.uuidString])
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    public func installApp(from url: URL) throws {
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"), arguments: ["simctl", "install", id.uuidString, url.path])
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    public func screenshot() throws -> Data {
        let temporaryDirectory = URL(FilePath.temporaryDirectory())
        let temporaryFile = temporaryDirectory!.appendingPathComponent("screenshot.png")
        
        let task = Process.Task(
            executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"),
            arguments: ["simctl", "io", id.uuidString, "screenshot", temporaryFile.path]
        )
        
        task.start()
        
        try task.waitUntilExit()
        
        let data = try Data(contentsOf: temporaryFile)
        
        try FileManager.default.removeItem(at: temporaryFile)
        
        return data
    }
    
    public func launchApp(withIdentifier appIdentifier: String)  throws{
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"), arguments: ["simctl", "launch", id.uuidString, appIdentifier])
        
        task.start()
        
        try task.waitUntilExit()
    }
    
    public func boot() throws {
        guard state != .booted else {
            return
        }
        
        let task = Process.Task(executableURL: URL(fileURLWithPath: "/usr/bin/xcrun"), arguments: ["simctl", "boot", id.uuidString])
        
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

extension SimulatorDevice {
    private static let handle = dlopen("/Library/Developer/PrivateFrameworks/CoreSimulator.framework/CoreSimulator", RTLD_NOW)
    
    public static func all() throws -> [Self] {
        _ = handle
        
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
}

#endif
