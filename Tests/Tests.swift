//
// Copyright (c) Vatsal Manot
//

@testable import SimulatorKit

import XCTest

final class SimulatorKitTests: XCTestCase {
    func testListingAllSimulatorDevices() throws {
        _ = try SimulatorDevice.all().first(where: { $0.name.contains("iPhone") })!
    }
    
    func testScreenshot() throws {
        let iphoneSimulator = try SimulatorDevice.all().first(where: { $0.name.contains("iPhone") })!
        
        try iphoneSimulator.boot()
        let jpgDataOfScreenshot: Data = try iphoneSimulator.screenshot()
        
        XCTAssert(!jpgDataOfScreenshot.isEmpty)
    }
}
