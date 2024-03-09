import Foundation
import i2pbridge

public final class Daemon {
    public let dataDir: URL
    public let configuration = Configuration()

    public enum Failure: Error {
        case unknown(String)
    }

    public init(dataDir: URL) {
        self.dataDir = dataDir
    }

    public func start() async throws {
        return try await withCheckedThrowingContinuation { [dataDir] continuation in
            DispatchQueue.global().async {
                i2pd_set_data_dir(dataDir.path)

                let error = String(cString: i2pd_start())
                guard error == "ok" else {
                    continuation.resume(throwing: Failure.unknown(error))
                    return
                }
                continuation.resume()
            }
        }
    }

    public func stop() async {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                i2pd_stop()
                continuation.resume()
            }
        }
    }
}

public final class Configuration {
    public var consoleURL: URL? {
        let address = String(cString: i2pd_get_string_option("http.address"))
        let port = i2pd_get_int_option("http.port")
        return URL(string: "http://\(address):\(port)")
    }

    public var httpProxyURL: URL? {
        let address = String(cString: i2pd_get_string_option("httpproxy.address"))
        let port = i2pd_get_int_option("httpproxy.port")
        return URL(string: "http://\(address):\(port)")
    }
}
