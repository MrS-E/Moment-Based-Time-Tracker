//
//  CapturePopoverView.swift
//  Moment Based Time Tracker
//
//  Created by Junie on 18.05.2026.
//

import SwiftUI

struct CapturePopoverView: View {
    var elapsedProvider: () -> String
    var onSave: (String) -> Void
    var onCancel: () -> Void

    @State private var note: String = ""

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
                .onSubmit { onSave(note) }

            HStack {
                Spacer()
                Button("Cancel") { onCancel() }
                Button("Save") { onSave(note) }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}

#if DEBUG
struct CapturePopoverView_Previews: PreviewProvider {
    static var previews: some View {
        CapturePopoverView(elapsedProvider: { "03:24" }, onSave: { _ in }, onCancel: { })
    }
}
#endif
