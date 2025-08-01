import Foundation
import Network
@testable import SwiftyI2P
import Testing

@Suite(.serialized)
class DaemonTests {
    private let dataDir = URL(fileURLWithPath: NSTemporaryDirectory())
        .appending(component: UUID().uuidString)

    @Test(.timeLimit(.minutes(1)))
    func start() async {
        await with(daemon: Daemon(dataDir: dataDir, configuration: Configuration())) { daemon in
            try await daemon.start()
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func socksProxy() async throws {
        await with(daemon: Daemon(dataDir: dataDir, configuration: Configuration())) { daemon in
            try await daemon.start()
            switch daemon.configuration.socksProxy {
            case let .hostPort(host: host, port: port):
                #expect(host == "127.0.0.1")
                #expect(port == 4447)
            default:
                Issue.record("untested")
            }
        }
    }

    @Test(.timeLimit(.minutes(1)))
    func setSocksProxy() async throws {
        var configuration = Configuration()
        configuration.socksProxy = .hostPort(host: "127.0.0.1", port: 4449)
        await with(daemon: Daemon(dataDir: dataDir, configuration: configuration)) { daemon in
            try await daemon.start()
            #expect(daemon.configuration.socksProxy == .hostPort(host: "127.0.0.1", port: 4449))
        }
    }

    @Test(.timeLimit(.minutes(2)))
    func setPortAndConnect() async throws {
        var configuration = Configuration()
        configuration.socksProxy = .hostPort(host: "127.0.0.1", port: 4449)
        await with(daemon: Daemon(dataDir: dataDir, configuration: configuration)) { daemon in
            try await daemon.start()
            let config = URLSessionConfiguration.default
            var proxy = try ProxyConfiguration(socksv5Proxy: #require(daemon.configuration.socksProxy))
            proxy.matchDomains = ["i2p"]
            config.proxyConfigurations = [proxy]
            let session = URLSession(configuration: config)
            let url = try #require(URL(string: "http://nytzrhrjjfsutowojvxi7hphesskpqqr65wpistz6wa7cpajhp7a.b32.i2p"))
            try await Task.sleep(for: .seconds(60))
            let (_, response) = try await session.data(for: URLRequest(url: url))
            #expect((response as? HTTPURLResponse)?.statusCode == 200)
        }
    }

    private func with(
        daemon: Daemon,
        fileID: String = #fileID,
        filePath: String = #filePath,
        line: Int = #line,
        column: Int = #column,
        closure: (Daemon) async throws -> Void
    ) async {
        do {
            try await closure(daemon)
        } catch {
            Issue.record(error)
        }

        await daemon.stop()
    }
}
