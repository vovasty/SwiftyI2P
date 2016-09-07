SwiftyI2P is an wrapper library for [i2pd](https://github.com/PurpleI2P/i2pd) written in Swift.

## Features

- [x] Start/stop i2pd daemon
- [x] Configuration
- [x] Host resolver

## Requirements

- iOS 9.0+
- Xcode 7.3+

## Installation

### Embedded Framework

- Run `bootstrap.sh` script in order to build dependencies:

```bash
$ ./bootstrap.sh
```

- Drag the `SwiftyI2P.xcodeproj` into the Project Navigator of your application's Xcode project.

    > It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.

- Select the `SwiftyI2P.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
- Next, select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the "Targets" heading in the sidebar.
- In the tab bar at the top of that window, open the "General" panel.
- Click on the `+` button under the "Embedded Binaries" section.
- Select `SwiftyI2P.framework` 

> The `SwiftyI2P.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

---

## Usage

### Starting daemon

```swift
import SwiftyI2P

let daemon = Daemon.defaultDaemon()
daemon.start()
```

>this will start i2pd daemon with socks proxy on port `4447`

## License

This project is licensed under the BSD 3-clause license, which can be found in the file LICENSE in the root of the project source code.
