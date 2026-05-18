//
//  ContentView.swift
//  Moment Based Time Tracker
//
//  Created by Simeon Stix on 18.05.2026.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var tracker: TimeTracker
    @Query(sort: \Item.timestamp, order: .reverse)
    private var items: [Item]
    @State private var now: Date = .init()
    private let headerTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            list
        }
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                if tracker.isTracking {
                    Button(role: .destructive) { tracker.stop() } label: {
                        Label("Stop Tracking", systemImage: "stop.fill")
                    }
                } else {
                    Button { tracker.start() } label: {
                        Label("Start Tracking", systemImage: "play.fill")
                    }
                }
            }
        }
        .padding()
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Moment Based Time Tracker")
                    .font(.title2).bold()
                Text(tracker.isTracking ? "Tracking… tap the menu bar ⏱ to capture a moment." : "Not tracking. Press Start to spawn the menu bar ⏱.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if tracker.isTracking {
                Text(tracker.currentElapsed().mmssString)
                    .monospacedDigit().font(.title3).padding(6).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .onReceive(headerTimer) { date in
                        // drive a state change to refresh the elapsed text every second
                        now = date
                    }
            }
        }
        .padding(.bottom, 8)
    }

    private var list: some View {
        List {
            if items.isEmpty {
                ContentUnavailableView("No moments yet", systemImage: "text.badge.plus", description: Text("Start tracking and use the ⏱ menu bar button to capture time with a description."))
            }
            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.note.isEmpty ? "(No description)" : item.note)
                            .font(.headline)
                        Text(item.timestamp, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(item.durationSeconds.mmssString)
                        .monospacedDigit()
                        .bold()
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.inset)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(items[index]) }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(TimeTracker(modelContext: try! ModelContainer(for: Schema([Item.self])) .mainContext))
}
