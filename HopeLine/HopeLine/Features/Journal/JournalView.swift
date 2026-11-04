//
//  JournalView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/3/26.
//

import SwiftUI

struct JournalView: View {

    @State private var showingNewEntry = false
    @State private var entries: [JournalEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Header

                VStack(alignment: .leading, spacing: 8) {
                    Text("📖 My Journal")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Take a moment to slow down and reflect.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }


                // MARK: - New Entry Button

                Button {
                    showingNewEntry = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "square.and.pencil")
                            .font(.title3)

                        Text("New Journal Entry")
                            .fontWeight(.semibold)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                }
                .buttonStyle(.plain)


                // MARK: - Reflection Prompt

                VStack(alignment: .leading, spacing: 10) {
                    Text("💭 Reflection")
                        .font(.headline)

                    Text(
                        "You don't have to have the right words. Just start with where you are today."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )


                // MARK: - Recent Entries

                VStack(alignment: .leading, spacing: 12) {

                    Text("Recent Entries")
                        .font(.title3)
                        .fontWeight(.semibold)

                    if isLoading {

                        loadingView

                    } else if let errorMessage {

                        errorView(message: errorMessage)

                    } else if entries.isEmpty {

                        emptyJournalView

                    } else {

                        ForEach(entries) { entry in
                            JournalEntryCard(entry: entry)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEntries()
        }
        .refreshable {
            await loadEntries()
        }
        .sheet(isPresented: $showingNewEntry) {

            NewJournalEntryView {
                Task {
                    await loadEntries()
                }
            }
        }
    }


    // MARK: - Load Entries

    @MainActor
    private func loadEntries() async {

        isLoading = true
        errorMessage = nil

        do {

            entries = try await JournalService.shared.fetchEntries()

        } catch {

            errorMessage = error.localizedDescription
        }

        isLoading = false
    }


    // MARK: - Loading View

    private var loadingView: some View {

        HStack(spacing: 12) {

            ProgressView()

            Text("Loading your journal...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }


    // MARK: - Error View

    private func errorView(message: String) -> some View {

        VStack(spacing: 12) {

            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(.orange)

            Text("Unable to load your journal")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await loadEntries()
                }
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }


    // MARK: - Empty Journal

    private var emptyJournalView: some View {

        VStack(spacing: 14) {

            Text("📝")
                .font(.system(size: 44))

            Text("Your journal is waiting")
                .font(.headline)

            Text(
                "Your journal entries will appear here after you begin writing."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal)
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - Journal Entry Card

private struct JournalEntryCard: View {

    let entry: JournalEntry

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Text(entry.content)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )

            Divider()

            HStack {

                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)

                Text(
                    entry.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}


// MARK: - New Journal Entry

private struct NewJournalEntryView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var entryText = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    @State private var showingError = false

    let onSave: () -> Void

    var body: some View {

        NavigationStack {

            VStack(alignment: .leading, spacing: 16) {

                Text("What's on your heart today?")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(
                    "Write freely. This is your space to reflect on your recovery, faith, struggles, victories, or whatever you're carrying today."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                TextEditor(text: $entryText)
                    .padding(10)
                    .frame(minHeight: 250)
                    .background(
                        Color(.secondarySystemBackground)
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .disabled(isSaving)

                if isSaving {

                    HStack(spacing: 10) {

                        ProgressView()

                        Text("Saving your journal entry...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled(isSaving)
            .toolbar {

                // MARK: Cancel

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isSaving)
                }


                // MARK: Save

                ToolbarItem(
                    placement: .confirmationAction
                ) {

                    Button {

                        saveJournalEntry()

                    } label: {

                        if isSaving {

                            ProgressView()

                        } else {

                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(
                        isSaving ||
                        entryText
                            .trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            .isEmpty
                    )
                }
            }
            .alert(
                "Unable to Save Journal Entry",
                isPresented: $showingError
            ) {

                Button("OK", role: .cancel) {}

            } message: {

                Text(
                    errorMessage ??
                    "Something went wrong while saving your journal entry."
                )
            }
        }
    }


    // MARK: - Save Journal Entry

    private func saveJournalEntry() {

        guard !isSaving else {
            return
        }

        isSaving = true
        errorMessage = nil

        Task {

            do {

                try await JournalService.shared.saveEntry(
                    content: entryText
                )

                await MainActor.run {

                    isSaving = false

                    onSave()

                    dismiss()
                }

            } catch {

                await MainActor.run {

                    isSaving = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}


// MARK: - Preview

#Preview {

    NavigationStack {
        JournalView()
    }
}
