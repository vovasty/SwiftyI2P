import Foundation
import i2pbridge
import os

public final class Daemon {
    private let isStarted = OSAllocatedUnfairLock(initialState: false)

    /// A path to i2pd data
    public let dataDir: URL

    /// An i2p configuration. Throws an error is daemon is not started.
    public var configuration: Configuration {
        get throws {
            guard isStarted.withLock({ $0 }) else {
                throw Failure.notStarted
            }
            return Configuration()
        }
    }

    public enum Failure: Error {
        case unknown(String)
        case notStarted
    }

    /// Constructs `Daemon` instance
    /// - Parameter dataDir: An existing path to i2pd data
    public init(dataDir: URL) {
        self.dataDir = dataDir
    }

    /// Start i2p.
    public func start() async throws {
        return try await withCheckedThrowingContinuation { [dataDir, isStarted] continuation in
            DispatchQueue.global().async {
                i2pd_set_data_dir(dataDir.path)

                let error = String(cString: i2pd_start())
                guard error == "ok" else {
                    continuation.resume(throwing: Failure.unknown(error))
                    return
                }
                isStarted.withLock {
                    $0 = true
                }
                continuation.resume()
            }
        }
    }

    /// Stop i2p
    public func stop() async {
        guard isStarted.withLock({ $0 }) else { return }
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                i2pd_stop()
                continuation.resume()
            }
        }
    }
}

public final class Configuration {
    /// An URL to i2p console
    public var consoleURL: URL? {
        let address = String(cString: i2pd_get_string_option("http.address"))
        let port = i2pd_get_int_option("http.port")
        return URL(string: "http://\(address):\(port)")
    }

    /// HTTP proxy URL
    public var httpProxyURL: URL? {
        let address = String(cString: i2pd_get_string_option("httpproxy.address"))
        let port = i2pd_get_int_option("httpproxy.port")
        return URL(string: "http://\(address):\(port)")
    }
}
