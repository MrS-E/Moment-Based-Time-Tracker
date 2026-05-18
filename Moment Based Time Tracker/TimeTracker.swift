//
//  TimeTracker.swift
//  Moment Based Time Tracker
//
//  Created by Junie on 18.05.2026.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class TimeTracker: ObservableObject {
    @Published private(set) var isTracking: Bool = false
    @Published private(set) var currentStart: Date?
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func start() {
        guard !isTracking else { return }
        isTracking = true
        let start = Date()
        currentStart = start

        // Generate an initial item on start (duration 0), so the timeline reflects the start moment
        let entry = Item(timestamp: start, durationSeconds: 0, note: "")
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            #if DEBUG
            print("Failed to save start entry: \(error)")
            #endif
        }
    }

    func stop() {
        guard isTracking else { return }
        isTracking = false
        currentStart = nil
    }

    func capture(note: String) {
        guard isTracking, let start = currentStart else { return }
        let end = Date()
        let duration = end.timeIntervalSince(start)
        // Avoid recording empty segments
        guard duration > 0.1 else { return }

        let entry = Item(timestamp: end, durationSeconds: duration, note: note)
        modelContext.insert(entry)
        do {
            try modelContext.save()
        } catch {
            // Non-fatal for now; persistence failure shouldn't break flow
            #if DEBUG
            print("Failed to save entry: \(error)")
            #endif
        }
        // Continue tracking seamlessly
        currentStart = end
    }

    func currentElapsed() -> TimeInterval {
        guard isTracking, let start = currentStart else { return 0 }
        return Date().timeIntervalSince(start)
    }
}

extension TimeInterval {
    var mmssString: String {
        // Use floor to avoid premature rounding up (e.g., 0.6s -> 1s)
        let total = Int(self)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
