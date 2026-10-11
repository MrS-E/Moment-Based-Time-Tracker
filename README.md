# Moment Based Time Tracker

A macOS menu bar app for lightweight, moment-based time tracking. Instead of juggling timers for every task, you start one tracking session and capture "moments" — each capture records the time segment that passed since your previous capture, along with a short description. Tracking continues seamlessly, so you can log what you were doing without ever stopping the clock.

## Features

- **Single continuous session** — start tracking once; every capture splits the session into a described segment.
- **Menu bar capture (⏱)** — while tracking, a menu bar item appears. Click it, type what you just spent time on, and save. The elapsed time is shown live.
- **Live elapsed timer** — the main window header shows `hh:mm:ss` updating every second while tracking.
- **Moment history** — captured moments are listed (newest first) with their description, timestamp, and duration. Moments can be deleted individually or via swipe.
- **Persistent storage** — all captured moments are stored on disk with SwiftData, so nothing is lost between launches.

## How It Works

1. Press **Start Tracking** in the main window (or the toolbar). A ⏱ item appears in the menu bar.
2. Whenever you finish a chunk of work, click the ⏱ item.
3. The popover shows how much time has passed since your last capture. Enter a description and hit **Save** (⏎).
4. The segment is recorded and the timer continues from that moment — no need to restart anything.
5. Press **Stop Tracking** when you're done; the menu bar item disappears.

## Tech Stack

- **SwiftUI** — all UI, including the `MenuBarExtra` popover and main window
- **SwiftData** — persistence for captured moments
- **AppKit** — `NSStatusItem`/`NSPopover` status bar integration

## Project Structure

| File | Purpose |
| --- | --- |
| `Moment Based Time Tracker/Moment_Based_Time_TrackerApp.swift` | App entry point; sets up the SwiftData container, main window, and `MenuBarExtra` scene |
| `Moment Based Time Tracker/TimeTracker.swift` | Core tracking engine (`ObservableObject`): start/stop, capture segments, elapsed time, duration formatting |
| `Moment Based Time Tracker/Item.swift` | SwiftData `@Model` for a captured moment (timestamp, duration, note) |
| `Moment Based Time Tracker/ContentView.swift` | Main window: start/stop controls, live elapsed header, moment history list |
| `Moment Based Time Tracker/CapturePopoverView.swift` | Popover UI for capturing a moment with a description |
| `Moment Based Time Tracker/StatusBarController.swift` | Optional `NSStatusItem`-based menu bar integration |

## Requirements

- macOS 14+ (Sonoma) — `MenuBarExtra` window style and SwiftData require recent OS APIs
- Xcode 15+

## Building and Running

1. Open `Moment Based Time Tracker.xcodeproj` in Xcode.
2. Select the `Moment Based Time Tracker` scheme and a **My Mac** destination.
3. Build and run with ⌘R.

## Data Model

Each captured moment is stored as an `Item`:

- `timestamp` — when the segment ended (the capture moment)
- `durationSeconds` — how long the segment lasted (from the previous capture or session start)
- `note` — user-provided description of the segment

Durations are displayed in `hh:mm` format; the live header timer shows `hh:mm:ss`.
