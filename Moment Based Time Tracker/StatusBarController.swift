//
//  StatusBarController.swift
//  Moment Based Time Tracker
//
//  Created by Junie on 18.05.2026.
//

import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private unowned let tracker: TimeTracker

    init(tracker: TimeTracker) {
        self.tracker = tracker
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureStatusItem()
        configurePopover()
    }

    private func configureStatusItem() {
        if let button = statusItem.button {
            button.title = "⏱"
            button.target = self
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp])
        }
        statusItem.isVisible = true
        statusItem.behavior = .removalAllowed
        statusItem.autosaveName = "MomentBasedTimeTrackerStatusItem"
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            let view = CapturePopoverView(
                elapsedProvider: { [weak tracker] in
                    (tracker?.currentElapsed() ?? 0).mmssString
                },
                onSave: { [weak self] text in
                    guard let self = self else { return }
                    self.tracker.capture(note: text)
                    self.popover.performClose(nil)
                },
                onCancel: { [weak self] in
                    self?.popover.performClose(nil)
                }
            )
            popover.contentViewController = NSHostingController(rootView: view)
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func remove() {
        if popover.isShown { popover.close() }
        NSStatusBar.system.removeStatusItem(statusItem)
    }
}
