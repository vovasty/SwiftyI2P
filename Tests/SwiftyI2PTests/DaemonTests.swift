@testable import SwiftyI2P
import XCTest

final class DaemonTests: XCTestCase {
    var dataDir: URL!
    var daemon: Daemon!

    override func setUp() async throws {
        try await super.setUp()
        dataDir = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(component: UUID().uuidString)
        daemon = Daemon(dataDir: dataDir)
    }

    override func tearDown() async throws {
        await daemon.stop()
        try await super.tearDown()
    }

    func testStart() async throws {
        let e = expectation(description: "test")
        Task {
            do {
                try await daemon.start()
            } catch {
                XCTFail("unexpected error \(error)")
            }
            e.fulfill()
        }

        await fulfillment(of: [e], timeout: 120)
    }

    func testHttpProxyUrl() async throws {
        try await daemon.start()
        let proxyUrl = try daemon.configuration.httpProxyURL
        XCTAssertEqual("127.0.0.1", proxyUrl?.host(percentEncoded: false))
        XCTAssertEqual(4444, proxyUrl?.port)
    }

    func testHttpProxyUrlNotStarted() async throws {
        XCTAssertThrowsError(try daemon.configuration.httpProxyURL)
    }
}
