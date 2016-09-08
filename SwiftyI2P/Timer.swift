//
//  Timer.swift
//  Nativa
//
//  Created by Vlad Solomenchuk on 8/27/14.
//  Copyright © 2015 Vladimir Solomenchuk.
//  This file is part of SwiftyI2p project and licensed under BSD3
//
//  See full license text in LICENSE file at top of project tree
//

import Foundation

class Timer {
    fileprivate let timer: DispatchSourceTimer

    init(timeout: Int,
                  queue: DispatchQueue = DispatchQueue.main,
             repeatable: Bool,
        fireImmediately: Bool = false,
                  block:@escaping (_ timer: Timer) -> Void) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer.setEventHandler { block(self) }

        let startTime = DispatchTime.now() + (fireImmediately ? 0.0 : Double(timeout))

        if repeatable {
            timer.scheduleRepeating(deadline: startTime,
                                    interval: DispatchTimeInterval.seconds(timeout))
        } else {
            timer.scheduleOneshot(deadline: startTime)
        }
    }

    func start() {
        timer.resume()
    }

    func stop() {
        timer.cancel()
    }

    deinit {
        timer.cancel()
    }
}
