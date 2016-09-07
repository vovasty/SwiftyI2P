//
//  SwiftyI2PTests.swift
//  SwiftyI2PTests
//
//  Created by Solomenchuk, Vlad on 12/18/15.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

import XCTest
@testable import SwiftyI2P

class SwiftyI2PTests: XCTestCase {
    var dataTask: NSURLSessionDataTask?

    func testLoad() throws {
        let daemon = Daemon.defaultDaemon
        daemon.start()

        let expectation = expectationWithDescription("testLoad")

        daemon.resolve("zmw2cyw2vj7f6obx3msmdvdepdhnw2ctc4okza2zjxlukkdfckhq.b32.i2p",
                       timeout: 1100) { (error) in

            XCTAssertNil(error)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1200, handler: nil)
        daemon.stop()
    }
}
