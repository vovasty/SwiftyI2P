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
    private var timer: dispatch_source_t!

    init(timeout: UInt64,
                  queue: dispatch_queue_t = dispatch_get_main_queue(),
             repeatable: Bool,
                  block:(timer: Timer) -> Void) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
        dispatch_source_set_event_handler(timer) {
            block(timer: self)
        }

        let interval = Int64(timeout * NSEC_PER_SEC)

        if repeatable {
            dispatch_source_set_timer(timer, dispatch_walltime(nil, interval), UInt64(interval), 0)
        } else {
            dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval),
                                      DISPATCH_TIME_FOREVER,
                                      0)
        }
    }

    func start() {
        guard let timer = timer else { return }

        dispatch_resume(timer)
    }

    func stop() {
        guard let timer = timer else { return }

        dispatch_source_cancel(timer)
        self.timer = nil
    }

    deinit {
        if let timer = timer {
            dispatch_source_cancel(timer)
        }
    }
}
