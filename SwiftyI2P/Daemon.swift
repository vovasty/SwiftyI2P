//
//  I2PDaemon.swift
//  SwiftyI2P
//
//  Created by Solomenchuk, Vlad on 12/19/15.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

import Foundation

private extension String {
    func stringByAppendingPathComponent(_ path: String) -> String {
        return (self as NSString).appendingPathComponent(path)
    }
}

extension I2PError: Error {
    public func message() -> String {
        switch self {
        case .OK:
            return "No Error"
        case .tryAgain:
            return "Site is currently unavailable."
        case .unresolvable:
            return "Host can not be resolved."
        case .timeout:
            return "Timeout."
        case .serviceNotStarted:
            return "I2PDaemon is not running."
        }
    }

    public func error() -> NSError {
        return NSError(domain: "net.aramzamzam.swiftyi2p",
                       code: self._code,
                       userInfo: [NSLocalizedDescriptionKey: message()])
    }
}

public enum State {
    case starting, running, stopped
}

public struct Config {
    public let host: (name: String, port: Int)
    public let datadir: String
    public let httpProxy: (port: Int, enabled: Bool)
    public let socksProxy: (port: Int, enabled: Bool)
    public let floodfill: Bool
    public let subscriptionsPath: String
    public let hostsPath: String
    public let addressbookPath: String

    init (host: (name: String, port: Int),
          datadir: String,
          httpProxy: (port: Int, enabled: Bool),
          socksProxy: (port: Int, enabled: Bool),
          floodfill: Bool) {
        self.host = host
        self.datadir = datadir
        self.httpProxy = httpProxy
        self.socksProxy = socksProxy
        self.floodfill = floodfill
        subscriptionsPath = datadir.stringByAppendingPathComponent("subscriptions.txt")
        hostsPath = datadir.stringByAppendingPathComponent("hosts.txt")
        addressbookPath = datadir
            .stringByAppendingPathComponent("addressbook")
            .stringByAppendingPathComponent("addresses.csv")
    }

    public static func defaultConfig() -> Config {
        return Config(
                host: ("127.0.0.1", 0),
             datadir: (NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                .userDomainMask,
                true).first ?? "/").stringByAppendingPathComponent("i2pd"),
           httpProxy: (4446, true),
          socksProxy: (4447, false),
           floodfill: true)
    }
}

open class Daemon {
    open fileprivate (set) var state: State = .stopped
    open let config: Config
    fileprivate let queue = DispatchQueue.global(qos: .background)

    open static var defaultDaemon: Daemon = Daemon()

    public init(config: Config = Config.defaultConfig()) {

        self.config = config

        let _ = "error".withCString {(logLevel) -> Int32 in
            config.host.name.withCString { (hostName) -> Int32 in
                config.datadir.withCString({ (datadir) -> Int32 in
                    let cfg = I2PConfig(
                        host: hostName,
                        datadir: datadir,
                        loglevel: logLevel,
                        port: Int32(config.host.port),
                        httpProxyPort: Int32(config.httpProxy.port),
                        httpProxyEnabled: config.httpProxy.enabled ? 1 : 0,
                        socksProxyPort: Int32(config.socksProxy.port),
                        socksProxyEnabled: config.socksProxy.enabled ? 1 : 0,
                        floodfill: config.floodfill ? 1 : 0)

                    return i2p_init(cfg)
                })
            }
        }
    }

    open func start() {
        guard state == .stopped else { return }

        state = .starting

        queue.async { () -> Void in
            i2p_start()
            self.state = .running
        }
    }

    open func stop() {
        guard state != .stopped else { return }

        i2p_stop()
        state = .stopped
    }
}

public extension Daemon {
    public func isReachable(host: String) -> I2PError {
        return i2p_is_reachable(host)
    }
}
