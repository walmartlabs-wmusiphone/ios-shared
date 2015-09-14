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
@objc public class PerformanceMonitor {

    /// Stores the times the various events got started
    private var startTimes: [String : NSDate] = [:]

    /// Records the total accumulated time for the topic
    private(set) var totalTime: NSTimeInterval = 0.0
    private(set) var topic: String

    /// This can be used to disable/enable performance monitoring for this object. Default is enabled.
    public var enabled: Bool = true

    init(topic: String) {
        self.topic = topic
    }

    init(topic: String, enabled: Bool) {
        self.topic = topic
        self.enabled = enabled
    }

    /// Start the timing for the given event
    public func start(eventName: String) {
        if !enabled {
            return
        }
        startTimes[eventName] = NSDate()
    }

    /// Stop the timing for the given event. Will log the time of the event to the debug console.
    public func stop(eventName: String) {
        if !enabled {
            return
        }
        if let fromDate = startTimes[eventName] {
            let eventDuration = NSDate().timeIntervalSinceDate(fromDate)
            totalTime += eventDuration
            println("PerformanceMonitor:(\(topic)): \(eventName) duration: \(eventDuration)s. totalTime \(totalTime)")
            startTimes[eventName] = nil
        }
    }

    /// Stops any current timing of events and resets the total time for the topic.
    public func reset() {
        if !enabled {
            return
        }
        let events = [String](startTimes.keys)
        for event in events {
            stop(event)
        }
        println("PerformanceMonitor:(\(topic)): reset(\(totalTime))")
        totalTime = 0.0
    }
}

/// Owns a "pool" of PerformanceMonitor objects grouped by topic.
/// Clients should use monitorForTopic to get PerformanceMonitor objects from the pool
@objc public class PerformanceMonitorPool {

    public static let sharedPool = PerformanceMonitorPool(enabled: true)

    /// This can be used to disable all performance monitoring. Default is enabled.
    public var enabled: Bool = true {
        didSet {
            for perfMon in pool.values {
                perfMon.enabled = enabled
            }
        }
    }

    init(enabled: Bool) {
        self.enabled = enabled
    }

    private var pool: [String:PerformanceMonitor] = [:]

    /// Gets or creates a PerformanceMonitor for a given "topic".
    public func monitorForTopic(topic: String) -> PerformanceMonitor {
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