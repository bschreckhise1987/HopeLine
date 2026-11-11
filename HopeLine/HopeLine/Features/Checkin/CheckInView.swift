//
//  CheckInView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI
internal import Auth
import Supabase

// The Daily Check-In screen: pick a category (like Struggling or
// Encouraged), select the feelings that apply, optionally add a note,
// then save the check-in to Supabase.
struct CheckInView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Services

    // Loads moods and saves check-ins.
    private let moodService = MoodService()

    // MARK: - State

    @State private var moods: [Mood] = []
    @State private var selectedCategory = ""
    @State private var selectedMoods: Set<Mood> = []
    @State private var note = ""

    @State private var isLoading = false
    @State private var isSaving = false

    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showSuccess = false

    // MARK: - Category Order

    // The order categories should appear in, best first. Categories not
    // in this list fall to the end alphabetically.
    private let preferredCategoryOrder = [
        "Encouraged",
        "Steady",
        "Growing",
        "Faith-Focused",
        "Recovery",
        "Mental Health",
        "Struggling"
    ]

    // MARK: - Computed Properties

    // Every category that has moods, in the preferred order, with any
    // unknown categories sorted on at the end.
    private var categories: [String] {
        let availableCategories = Set(
            moods.map(\.category)
        )

        let orderedCategories = preferredCategoryOrder.filter {
            availableCategories.contains($0)
        }

        let remainingCategories = availableCategories
            .filter {
                !preferredCategoryOrder.contains($0)
            }
            .sorted()

        return orderedCategories + remainingCategories
    }

    // The moods for the currently selected category, sorted by name.
    private var displayedMoods: [Mood] {
        moods
            .filter {
                $0.category == selectedCategory
            }
            .sorted {
                $0.name < $1.name
            }
    }

    // The Save button is enabled only once a category and at least one
    // mood are selected and nothing is currently saving.
    private var canSave: Bool {
        !selectedCategory.isEmpty &&
        !selectedMoods.isEmpty &&
        !isSaving
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                introductionSection

                if isLoading {
                    loadingSection
                } else if moods.isEmpty {
                    emptyStateSection
                } else {
                    categorySection
                    moodSection
                    reflectionSection
                    saveSection
                }
            }
            .padding()
        }
        .navigationTitle("Daily Check-In")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadMoods()
        }
        .alert(
            "Unable to Complete Check-In",
            isPresented: $showError
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                errorMessage ??
                "Something went wrong. Please try again."
            )
        }
        .alert(
            "Check-In Saved",
            isPresented: $showSuccess
        ) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text(
                "Your Daily Check-In was saved successfully."
            )
        }
    }

    // MARK: - Introduction

    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("How are you doing today?")
                .font(.title)
                .fontWeight(.bold)

            Text(
                "Choose the category and feelings that best describe where you are today."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()

            Text("Loading your HopeLine moods...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 240
        )
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("No moods are available.")
                .font(.headline)

            Text(
                "HopeLine could not load the mood list."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("Try Again") {
                Task {
                    await loadMoods()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 240
        )
    }

    // MARK: - Category

    // The horizontal row of category pills the user picks from first.
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How would you describe today?")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose one category to begin.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack(spacing: 10) {
                    ForEach(
                        categories,
                        id: \.self
                    ) { category in

                        categoryButton(for: category)
                    }
                }
            }
        }
    }

    // One selectable category pill — blue when selected.
    private func categoryButton(
        for category: String
    ) -> some View {
        Button {
            selectCategory(category)
        } label: {
            Text(category)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(
                    selectedCategory == category
                        ? Color.white
                        : Color.primary
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    selectedCategory == category
                        ? Color.blue
                        : Color(.secondarySystemBackground)
                )
                .clipShape(
                    Capsule()
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Moods

    // The grid of mood cards for the selected category.
    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedCategory)
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Select all that apply.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !selectedMoods.isEmpty {
                    Text("\(selectedMoods.count) selected")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(
                        .flexible(),
                        spacing: 12
                    ),
                    GridItem(
                        .flexible(),
                        spacing: 12
                    )
                ],
                spacing: 12
            ) {
                ForEach(displayedMoods) { mood in
                    moodButton(for: mood)
                }
            }
        }
    }

    // One mood card: emoji, name, and a checkmark ring when selected.
    private func moodButton(
        for mood: Mood
    ) -> some View {
        let isSelected = selectedMoods.contains(mood)

        return Button {
            toggleMood(mood)
        } label: {
            VStack(spacing: 10) {
                Text(mood.emoji)
                    .font(.system(size: 34))

                Text(mood.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Image(
                    systemName: isSelected
                        ? "checkmark.circle.fill"
                        : "circle"
                )
                .foregroundStyle(
                    isSelected
                        ? Color.blue
                        : Color.secondary
                )
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 130
            )
            .padding(12)
            .background(
                Color(.secondarySystemBackground)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected
                            ? Color.blue
                            : Color.clear,
                        lineWidth: 2
                    )
            }
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reflection

    // The optional note about what's happening today.
    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What's on your mind?")
                .font(.title2)
                .fontWeight(.semibold)

            Text(
                "You can add a note about what is happening today."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            TextEditor(text: $note)
                .frame(minHeight: 120)
                .padding(8)
                .scrollContentBackground(.hidden)
                .background(
                    Color(.systemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }

    // MARK: - Save

    // The Save button with its loading state and encouragement caption.
    private var saveSection: some View {
        VStack(spacing: 12) {
            Button {
                Task {
                    await saveCheckIn()
                }
            } label: {
                HStack {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(
                            systemName: "heart.fill"
                        )
                    }

                    Text(
                        isSaving
                            ? "Saving Check-In..."
                            : "Save Check-In"
                    )
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!canSave)

            Text(
                "Your check-ins can help you recognize patterns throughout your recovery journey."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Load Moods

    // Fetches the mood list when the screen appears and selects the
    // first category by default.
    @MainActor
    private func loadMoods() async {
        isLoading = true
        errorMessage = nil

        do {
            moods = try await moodService.fetchMoods()

            if selectedCategory.isEmpty {
                selectedCategory =
                    categories.first ?? ""
            }
        } catch {
            moods = []
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    // MARK: - Save Check-In

    // Saves the check-in for the signed-in user. Requires being signed
    // in; shows a success alert and dismisses on completion.
    @MainActor
    private func saveCheckIn() async {
        guard canSave else {
            return
        }

        guard let user =
                SupabaseManager.shared.client.auth.currentUser
        else {
            errorMessage =
                "You must be signed in before saving a check-in."
            showError = true
            return
        }

        isSaving = true
        errorMessage = nil

        do {
            _ = try await moodService.createCheckIn(
                userId: user.id,
                category: selectedCategory,
                notes: note,
                selectedMoods: Array(selectedMoods)
            )

            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isSaving = false
    }

    // MARK: - Selection Helpers

    // Switching categories clears the selected moods, since moods
    // belong to their category.
    private func selectCategory(
        _ category: String
    ) {
        guard category != selectedCategory else {
            return
        }

        selectedCategory = category
        selectedMoods.removeAll()
    }

    // Taps a mood on or off the selected set.
    private func toggleMood(
        _ mood: Mood
    ) {
        if selectedMoods.contains(mood) {
            selectedMoods.remove(mood)
        } else {
            selectedMoods.insert(mood)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckInView()
    }
}
