//
//  Item.swift
//  Moment Based Time Tracker
//
//  Created by Simeon Stix on 18.05.2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    // The time the segment ended (capture moment)
    var timestamp: Date
    // Duration of the segment in seconds
    var durationSeconds: Double
    // User-provided description for the captured time segment
    var note: String

    init(timestamp: Date, durationSeconds: Double = 0, note: String = "") {
        self.timestamp = timestamp
        self.durationSeconds = durationSeconds
        self.note = note
    }
}
