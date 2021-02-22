//
// Copyright (c) Vatsal Manot
//

@testable import SimulatorKit

import XCTest

final class SimulatorKitTests: XCTestCase {
    func testListingAllSimulatorDevices() throws {
        _ = try SimulatorDevice.all()
    }
}
