//
//  I2PReachability.swift
//  SwiftyI2P
//
//  Created by Solomenchuk, Vlad on 1/9/16.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

import Foundation

public struct Resolver {
    let timer: Timer

    public init(host: String,
              daemon: Daemon,
             timeout: NSTimeInterval,
             closure: (I2PError?) -> Void) {

        let endTime = NSDate().dateByAddingTimeInterval(timeout)
        timer = Timer(timeout: 5, repeatable: true) { (timer) -> Void in
            guard NSDate().compare(endTime) != .OrderedDescending else {
                timer.stop()
                closure(I2PError.Timeout)
                return
            }

            switch daemon.state {
            case .starting:
                return
            case .stopped:
                timer.stop()
                closure(I2PError.ServiceNotStarted)
                return
            case .running:
                let error = i2p_is_reachable(host)

                switch error {
                case .OK:
                    timer.stop()
                    closure(nil)
                case .TryAgain:
                    return
                default:
                    timer.stop()
                    closure(error)
                }
            }
        }
    }

    public func start() {
        timer.start()
    }

    public func stop() {
        timer.stop()
    }
}

public extension Daemon {
    public func resolve(host: String,
                     timeout: NSTimeInterval,
                     closure: (I2PError?) -> Void) -> Resolver {

        let resolver = Resolver(host: host,
                                 daemon: self,
                                timeout: timeout,
                                closure: closure)

        resolver.start()
        return resolver
    }
}
