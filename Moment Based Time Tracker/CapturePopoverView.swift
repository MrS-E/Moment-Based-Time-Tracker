//
//  CapturePopoverView.swift
//  Moment Based Time Tracker
//
//  Created by Junie on 18.05.2026.
//

import SwiftUI
import Combine

struct CapturePopoverView: View {
    var elapsedProvider: () -> String
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""
    @State private var now: Date = .init()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Time passed:")
                Text(elapsedProvider())
                    .monospacedDigit()
                    .bold()
            }

            TextField("Add a description…", text: $note)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    let text = note
                    note = ""
                    onSave(text)
                    dismiss()
                }

            HStack {
                Spacer()
                Button("Cancel") {
                    note = ""
                    onCancel()
                    dismiss()
                }
                Button("Save") {
                    let text = note
                    note = ""
                    onSave(text)
                    dismiss()
                }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .frame(width: 280)
        // Drive view updates every second so the elapsed text stays live
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
    }
}

#if DEBUG
struct CapturePopoverView_Previews: PreviewProvider {
    static var previews: some View {
        CapturePopoverView(elapsedProvider: { "03:24" }, onSave: { _ in }, onCancel: { })
    }
}
#endif
