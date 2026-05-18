//
//  Moment_Based_Time_TrackerApp.swift
//  Moment Based Time Tracker
//
//  Created by Simeon Stix on 18.05.2026.
//

import SwiftUI
import SwiftData

@main
struct Moment_Based_Time_TrackerApp: App {
    let sharedModelContainer: ModelContainer
    @StateObject private var tracker: TimeTracker

    init() {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.sharedModelContainer = container
            _tracker = StateObject(wrappedValue: TimeTracker(modelContext: container.mainContext))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tracker)
        }
        .modelContainer(sharedModelContainer)

        // Menu bar popover for capturing a moment while tracking
        // Shown only while tracking to mimic spawning/removing the status item
        if tracker.isTracking {
            MenuBarExtra {
                CapturePopoverView(
                    elapsedProvider: { tracker.currentElapsed().mmssString },
                    onSave: { text in
                        tracker.capture(note: text)
                    },
                    onCancel: { /* SwiftUI will auto-close the window-style popover */ }
                )
                .frame(minWidth: 280)
            } label: {
                Text("⏱")
            }
            .menuBarExtraStyle(.window)
        }
    }
}
