//
//  ScriptureReflectionView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/6/26.
//

import SwiftUI
import Supabase

// MARK: - Scripture Reflection View
// The sheet shown when the user taps "Reflect in Journal".
// Pre-fills a Journal entry with the Scripture, its
// reference, and the reflection prompt, so the user's
// own thoughts are written alongside the verse that
// inspired them.

struct ScriptureReflectionView: View {

    // The verse being reflected on.
    let verseReference: String
    let verseText: String

    // The reflection question (falls back to
    // the standard prompt).
    var reflectionPrompt: String? = nil

    // The saved-entry confirmation handler.
    var onSaved: () -> Void = {}

    // Uses the shared service instance — JournalService
    // has a private initializer (singleton pattern).
    private let journalService = JournalService.shared

    @Environment(\.dismiss) private var dismiss

    // The user's written reflection, pre-filled
    // with the Scripture block.
    @State private var entryText = ""

    @State private var isSaving = false
    @State private var errorMessage: String?

    // The complete starting text for the entry:
    // the verse, its reference, and the prompt,
    // with room for the user's own words below.
    private var starterText: String {

        let prompt =
            reflectionPrompt
            ?? "What does this Scripture speak to in what you're walking through today?"

        return
            "📖 \(verseReference)\n\n" +
            "\(verseText)\n\n" +
            "💭 \(prompt)\n\n"
    }

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    // MARK: Instruction

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        Text(
                            "💭 Reflect in Journal"
                        )
                        .font(.title2)
                        .fontWeight(.semibold)

                        Text(
                            "The Scripture and prompt are included below. Write whatever is on your heart."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    // MARK: Error

                    if let errorMessage {

                        // Shown when the entry can't
                        // be saved.
                        Label(
                            errorMessage,
                            systemImage:
                                "exclamationmark.triangle.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    }

                    // MARK: Entry Text

                    TextEditor(
                        text: $entryText
                    )
                    .frame(
                        minHeight: 320,
                        alignment: .leading
                    )
                    .padding(8)
                    .background(
                        Color(
                            .secondarySystemBackground
                        )
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .scrollContentBackground(
                        .hidden
                    )

                    // MARK: Save Button

                    Button {

                        Task {
                            await saveEntry()
                        }

                    } label: {

                        HStack(spacing: 10) {

                            if isSaving {

                                // Small spinner shown while
                                // the entry is saving.
                                ProgressView()
                                    .tint(.white)
                            }

                            Label(
                                "Save to Journal",
                                systemImage:
                                    "square.and.pencil"
                            )
                            .fontWeight(.semibold)
                            .frame(
                                maxWidth: .infinity
                            )
                        }
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                    .disabled(
                        // Disabled while saving or when
                        // the entry is empty.
                        isSaving ||
                        entryText
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
                .padding()
            }
            .navigationTitle("Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

                ToolbarItem(
                    placement: .topBarLeading
                ) {

                    Button(
                        "Cancel"
                    ) {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .topBarTrailing
                ) {

                    Button(
                        "Done"
                    ) {
                        dismiss()
                    }
                }
            }
            .task {
                // Pre-fills the entry with the Scripture
                // block the first time the sheet opens.
                if entryText.isEmpty {
                    entryText = starterText
                }
            }
        }
    }

    // MARK: - Save Entry
    // Saves the reflection as a Journal entry
    // through the existing JournalService.

    private func saveEntry() async {

        isSaving = true
        errorMessage = nil

        do {

            try await journalService
                .saveEntry(
                    content: entryText
                )

            // Confirms success back to the parent
            // screen, then closes the sheet.
            onSaved()

            dismiss()
        }

        catch {

            // Journal entries require a signed-in
            // account; other failures show a generic
            // retry message.
            if error is AuthError {
                errorMessage =
                    "Sign in to write in your Journal."
            } else {
                errorMessage =
                    "HopeLine couldn't save your entry. Check your internet connection and try again."
            }
        }

        isSaving = false
    }
}

// MARK: - Preview

#Preview {

    ScriptureReflectionView(
        verseReference: "Philippians 4:6-7",
        verseText:
            "In nothing be anxious, but in everything, by prayer and petition with thanksgiving, let your requests be made known to God."
    )
}
