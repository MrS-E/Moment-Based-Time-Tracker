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
    // No explicit timer state here; use TimelineView for deterministic 1s updates

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
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(headerElapsedText(at: context.date))
                        .monospacedDigit()
                        .font(.title3)
                        .padding(6)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
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
                    Button(role: .destructive) {
                        withAnimation {
                            modelContext.delete(item)
                            do { try modelContext.save() } catch {
                                #if DEBUG
                                print("Failed to delete item: \(error)")
                                #endif
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.borderless)
                    .help("Delete")
                }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.inset)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets { modelContext.delete(items[index]) }
            do { try modelContext.save() } catch {
                #if DEBUG
                print("Failed to save deletions: \(error)")
                #endif
            }
        }
    }

    // Show seconds in the header so the value visibly updates every second while tracking.
    // The rest of the app keeps using the hh:mm format.
    private func headerElapsedText(at date: Date) -> String {
        guard let start = tracker.currentStart else { return "00:00:00" }
        let total = Int(date.timeIntervalSince(start))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
        .environmentObject(TimeTracker(modelContext: try! ModelContainer(for: Schema([Item.self])) .mainContext))
}
