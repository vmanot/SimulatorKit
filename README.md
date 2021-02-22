SimulatorKit is a framework that wraps `CoreSimulator` and `simctl` to offer programmatic access to the Simulator app bundled with Xcode.

- macOS 11
- Swift 5.3
- Xcode 12

# Installation

The preferred way of installing SimulatorKit is via the [Swift Package Manager](https://swift.org/package-manager/).

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/vmanot/SimulatorKit`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.

# Why 

The goal of this framework is to provide a safe and idiomatic way to control the Simulator app. 

# Usage

Almost all functions on `SimulatorDevice` are synchronous, blocking and throwing.

#### List all available simulators
```
import SimulatorKit

print(try! SimulatorDevice.all())
```

#### Boot a simulator
```
import SimulatorKit

let iphoneSimulator = try SimulatorDevice.all().first(where: { $0.name.contains("iPhone") })!

try iphoneSimulator.boot()
```

#### Take a screenshot of a simulator
```
import SimulatorKit

let iphoneSimulator = try SimulatorDevice.all().first(where: { $0.name.contains("iPhone") })!

let jpgDataOfScreenshot: Data = try iphoneSimulator.screenshot()
```
