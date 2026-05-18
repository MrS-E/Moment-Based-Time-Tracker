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

    var body: some Scene { scenes }

    // Work around potential compiler issues by building scenes in a separate @SceneBuilder
    @SceneBuilder private var scenes: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tracker)
                // Ensure the main window is visible on launch with a sensible minimum size
                .frame(minWidth: 520, minHeight: 420)
        }
        .modelContainer(sharedModelContainer)

        // Menu bar popover for capturing a moment while tracking
        // Use isInserted binding to control presence instead of conditional scenes
        MenuBarExtra(isInserted: .init(
            get: { tracker.isTracking },
            set: { _ in }
        )) {
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
