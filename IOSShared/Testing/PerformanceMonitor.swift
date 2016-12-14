//
//  PerformanceMonitor.swift
//  walmart
//
//  Created by David Pettigrew on 9/10/15.
//  Copyright (c) 2015 Walmart. All rights reserved.
//

import Foundation

/**
A class that records durations of events.
Clients specify the "topic" name. This allows an app to have different and easily identifiable topics to monitor.
Performance is computed as the difference between the start and stop method calls in addition to the total time for the topic.
So you can track time spent at a granular level (e.g. by individual operations/methods) and also for a topic (e.g. a complete view controller setup)
Currently this is just in the form of formatted messages to the printed to the debug console.
*/
@objc open class PerformanceMonitor: NSObject {

    /// Stores the times the various events got started
    fileprivate var startTimes: [String : Date] = [:]

    /// Records the total accumulated time for the topic
    fileprivate(set) var totalTime: TimeInterval = 0.0
    fileprivate(set) var topic: String
    fileprivate(set) var eventTimeLimits: [String : Double] = [:]

    /// This can be used to disable/enable performance monitoring for this object. Default is enabled.
    open var enabled: Bool = true

    init(topic: String, enabled: Bool = true) {
        self.topic = topic
        self.enabled = enabled
    }

    /// Start the timing for the given event
    open func start(_ eventName: String, timeLimit: TimeInterval) {
        if !enabled {
            return
        }
        startTimes[eventName] = Date()
        eventTimeLimits[eventName] = Double(timeLimit)
    }

    /// Stop the timing for the given event. Will log the time of the event to the debug console.
    open func stop(_ eventName: String) {
        if !enabled {
            return
        }
        if let fromDate = startTimes[eventName] {
            let eventDuration = Date().timeIntervalSince(fromDate)
            if let eventTimeLimit = eventTimeLimits[eventName] {
                if Double(eventDuration) > eventTimeLimit {
                    print("PerformanceMonitor:(\(topic)): Warning: \(eventName) duration: \(eventDuration)s exceeds limit of \(eventTimeLimit)s.")
                }
            }
            totalTime += eventDuration
            startTimes[eventName] = nil
        }
    }

    /// Stops any current timing of events and resets the total time for the topic.
    open func reset() {
        if !enabled {
            return
        }
        let events = [String](startTimes.keys)
        for event in events {
            stop(event)
        }
        totalTime = 0.0
    }

    open func log(_ eventName: String) {
        print("PerformanceMonitor:(\(topic)): totalTime \(totalTime)")
    }
}

/// Owns a "pool" of PerformanceMonitor objects grouped by topic.
/// Clients should use monitorForTopic to get PerformanceMonitor objects from the pool
@objc open class PerformanceMonitorPool: NSObject {

    open static let sharedPool = PerformanceMonitorPool(enabled: true)

    /// This can be used to disable all performance monitoring. Default is enabled.
    open var enabled: Bool = true {
        didSet {
            for perfMon in pool.values {
                perfMon.enabled = enabled
            }
        }
    }

    init(enabled: Bool) {
        self.enabled = enabled
    }

    fileprivate var pool: [String:PerformanceMonitor] = [:]

    /// Gets or creates a PerformanceMonitor for a given "topic".
    open func monitorForTopic(_ topic: String) -> PerformanceMonitor {
        if let perfmon = pool[topic] {
            return perfmon
        }
        else {
            let newPerfMon = PerformanceMonitor(topic: topic, enabled: enabled)
            pool[topic] = newPerfMon
            return newPerfMon
        }
    }
}
