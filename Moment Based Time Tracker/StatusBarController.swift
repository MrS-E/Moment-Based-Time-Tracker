//
//  StatusBarController.swift
//  Moment Based Time Tracker
//
//  Created by Junie on 18.05.2026.
//

import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject, NSPopoverDelegate {
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var hostingController: NSHostingController<CapturePopoverView>?
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
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.delegate = self
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(sender)
        } else {
            // Build or update a single reusable hosting controller to avoid scene churn
            let buildView: () -> CapturePopoverView = { [weak self] in
                guard let self = self else { return CapturePopoverView(elapsedProvider: { "00:00" }, onSave: { _ in }, onCancel: {}) }
                return CapturePopoverView(
                    elapsedProvider: { [weak self] in
                        guard let self = self else { return "00:00" }
                        return self.tracker.currentElapsed().mmssString
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
            }

            if hostingController == nil {
                hostingController = NSHostingController(rootView: buildView())
            } else {
                hostingController?.rootView = buildView()
            }
            popover.contentViewController = hostingController
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func remove() {
        if popover.isShown { popover.close() }
        // Release hosted SwiftUI view to allow its scene to disconnect cleanly
        popover.contentViewController = nil
        hostingController = nil
        // Defer removal to the next runloop to avoid "Unhandled disconnected scene" console spam
        DispatchQueue.main.async { [statusItem] in
            NSStatusBar.system.removeStatusItem(statusItem)
        }
    }

    // MARK: - NSPopoverDelegate
    func popoverWillClose(_ notification: Notification) {
        // Clear content to proactively tear down the hosted SwiftUI scene
        popover.contentViewController = nil
        hostingController = nil
    }
}
