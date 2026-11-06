//
//  ScriptureView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/6/26.
//

import SwiftUI

struct ScriptureView: View {

    // MARK: - State

    @State private var isSaved = false

    // Today's Scripture loaded from Supabase.
    @State private var scripture: DailyScripture?
    @State private var isLoading = true
    @State private var errorMessage: String?

    // The theme sheet state. When a theme row is
    // tapped, this holds the selected theme.
    @State private var selectedTheme: ScriptureTheme?

    // Uses the shared service instance — ScriptureService
    // has a private initializer (singleton pattern).
    private let scriptureService = ScriptureService.shared

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 24
            ) {

                // MARK: - Header

                VStack(
                    alignment: .leading,
                    spacing: 8
                ) {

                    Text("📖 Daily Scripture")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Truth and encouragement for where you are today."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Today Card

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    Label(
                        "For Where You Are Today",
                        systemImage: "heart.text.square.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(.blue)

                    if isLoading {

                        // Shown while today's Scripture
                        // is being fetched.
                        HStack(spacing: 12) {

                            ProgressView()

                            Text(
                                "Finding today's Scripture..."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 80,
                            alignment: .leading
                        )
                    }

                    else if let errorMessage {

                        // Shown when the Scripture
                        // couldn't be loaded.
                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Label(
                                "Couldn't Load Scripture",
                                systemImage:
                                    "exclamationmark.triangle.fill"
                            )
                            .font(.headline)
                            .foregroundStyle(.orange)

                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button(
                                "Try Again"
                            ) {
                                Task {
                                    await loadScripture()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    else if let scripture {

                        // Today's verse, straight from
                        // the daily_scriptures table.
                        Text(
                            "A Scripture selected to encourage you in today's journey."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Divider()

                        // MARK: Scripture

                        Text(
                            scripture.verseText
                        )
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)

                        Text(
                            scripture.verseReference
                        )
                        .font(.headline)
                        .foregroundStyle(.blue)

                        // MARK: Prayer

                        // The short prayer saved with
                        // this Scripture in the database.
                        if let prayer = scripture.prayer {

                            Divider()

                            Label(
                                "A Prayer for Today",
                                systemImage:
                                    "hands.sparkles.fill"
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)

                            Text(
                                prayer
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineSpacing(4)
                        }

                        // MARK: Save

                        Button {

                            isSaved.toggle()

                        } label: {

                            Label(
                                isSaved
                                    ? "Saved"
                                    : "Save Scripture",
                                systemImage:
                                    isSaved
                                    ? "bookmark.fill"
                                    : "bookmark"
                            )
                            .frame(
                                maxWidth: .infinity
                            )
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
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

                // MARK: - Check-In Connection

                VStack(
                    alignment: .leading,
                    spacing: 12
                ) {

                    Label(
                        "Connected to Your Journey",
                        systemImage: "heart.fill"
                    )
                    .font(.headline)

                    Text(
                        "HopeLine will use your daily check-in to help connect you with Scripture that speaks to what you're walking through."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    HStack(spacing: 8) {

                        ScriptureTag(
                            text: "Struggling"
                        )

                        ScriptureTag(
                            text: "Anxious"
                        )
                    }

                    Text(
                        "Personalized Scripture recommendations are coming as HopeLine continues to grow."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color.blue.opacity(0.08)
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                // MARK: - Reflection

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    HStack {

                        Label(
                            "Reflection",
                            systemImage: "book.closed.fill"
                        )
                        .font(.title3)
                        .fontWeight(.semibold)

                        Spacer()
                    }

                    // The reflection prompt saved with
                    // this Scripture in the database.
                    Text(
                        scripture?.reflectionPrompt
                            ?? "What does this Scripture speak to in what you're walking through today?"
                    )
                    .font(.body)

                    Text(
                        "Take a moment to slow down, reflect, and write whatever is on your heart."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Button {
                        // Journal connection comes next.
                    } label: {

                        Label(
                            "Reflect in Journal",
                            systemImage:
                                "square.and.pencil"
                        )
                        .fontWeight(.semibold)
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                }
                .padding()
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

                // MARK: - When You Need Encouragement

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    Text(
                        "When You Need Encouragement"
                    )
                    .font(.title2)
                    .fontWeight(.semibold)

                    Text(
                        "Explore Scripture based on what you're facing."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    // One tappable row per theme. Tapping
                    // opens the theme's Scripture pool.
                    ForEach(
                        ScriptureTheme.allCases
                    ) { theme in

                        ScriptureCategoryRow(
                            theme: theme
                        ) {
                            selectedTheme = theme
                        }
                    }
                }

                // MARK: - HopeLine Message

                VStack(
                    alignment: .leading,
                    spacing: 10
                ) {

                    Label(
                        "One Day at a Time",
                        systemImage:
                            "sun.max.fill"
                    )
                    .font(.headline)

                    Text(
                        "You don't have to have everything figured out today. Take what you need for this moment and keep moving forward."
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
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )
            }
            .padding()
        }
        .navigationTitle("Scripture")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Loads today's Scripture when
            // the screen first appears.
            await loadScripture()
        }
        .sheet(
            item: $selectedTheme
        ) { theme in

            // Shows the Scripture pool for the
            // theme the user tapped.
            ThemeScripturesView(
                theme: theme
            )
        }
    }

    // MARK: - Load Scripture
    // Fetches today's Scripture from the database and
    // records that the user viewed it.

    private func loadScripture() async {

        isLoading = true
        errorMessage = nil

        do {

            let todayScripture =
                try await scriptureService
                    .fetchDailyScripture()

            scripture = todayScripture

            // Logs the view for signed-in users;
            // does nothing when not signed in.
            await scriptureService
                .recordView(
                    scriptureId: todayScripture.id
                )
        }

        catch {

            errorMessage =
                "HopeLine couldn't load today's Scripture. Check your internet connection and try again."
        }

        isLoading = false
    }
}

// MARK: - Scripture Tag

private struct ScriptureTag: View {

    let text: String

    var body: some View {

        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(.blue)
            .padding(
                .horizontal,
                10
            )
            .padding(
                .vertical,
                6
            )
            .background(
                Color.blue.opacity(0.10)
            )
            .clipShape(
                Capsule()
            )
    }
}

// MARK: - Scripture Category Row
// One tappable theme row in the exploration section.

private struct ScriptureCategoryRow: View {

    let theme: ScriptureTheme

    // Called when the row is tapped.
    let onTap: () -> Void

    var body: some View {

        Button {
            onTap()
        } label: {

            HStack(spacing: 14) {

                Text(theme.emoji)
                    .font(.title2)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(theme.title)
                        .font(.headline)
                        .foregroundStyle(
                            .primary
                        )

                    Text(theme.subtitle)
                        .font(.caption)
                        .foregroundStyle(
                            .secondary
                        )
                }

                Spacer()

                Image(
                    systemName:
                        "chevron.right"
                )
                .font(.caption)
                .foregroundStyle(
                    .secondary
                )
            }
            .padding()
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
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Theme Scriptures View
// The sheet shown when a theme is tapped. Lists every
// Scripture in that theme's pool so the user can read
// several and choose one to hold onto.

private struct ThemeScripturesView: View {

    let theme: ScriptureTheme

    // The theme's Scriptures loaded from Supabase.
    @State private var scriptures: [ThemeScripture] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    // The verse the user tapped to hold onto.
    @State private var selectedScripture: ThemeScripture?

    // Uses the shared service instance — ScriptureService
    // has a private initializer (singleton pattern).
    private let scriptureService = ScriptureService.shared

    @Environment(\.dismiss) private var dismiss

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {

                    // MARK: Theme Header

                    VStack(
                        alignment: .leading,
                        spacing: 6
                    ) {

                        Text(
                            "\(theme.emoji) \(theme.title)"
                        )
                        .font(.title2)
                        .fontWeight(.semibold)

                        Text(
                            theme.subtitle
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )

                    // MARK: Scripture List

                    if isLoading {

                        // Shown while the theme's pool loads.
                        HStack(spacing: 12) {

                            ProgressView()

                            Text(
                                "Finding Scriptures..."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .frame(
                            maxWidth: .infinity,
                            minHeight: 100,
                            alignment: .center
                        )
                    }

                    else if let errorMessage {

                        // Shown when the pool can't load.
                        VStack(
                            alignment: .leading,
                            spacing: 12
                        ) {

                            Label(
                                "Couldn't Load Scriptures",
                                systemImage:
                                    "exclamationmark.triangle.fill"
                            )
                            .font(.headline)
                            .foregroundStyle(.orange)

                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button(
                                "Try Again"
                            ) {
                                Task {
                                    await loadScriptures()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
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
                    }

                    else if scriptures.isEmpty {

                        // Shown when the theme has no
                        // Scriptures yet.
                        Text(
                            "No Scriptures are in this theme yet. Check back soon."
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    else {

                        // One card per Scripture in the
                        // theme pool.
                        ForEach(scriptures) { scripture in

                            ThemeScriptureCard(
                                scripture: scripture,
                                isSelected:
                                    selectedScripture?
                                        .id == scripture.id
                            ) {
                                // Tapping a Scripture selects it as
                                // the one the user is holding onto.
                                selectedScripture = scripture
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Scriptures")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {

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
                // Loads the theme's Scripture pool
                // when the sheet first appears.
                await loadScriptures()
            }
        }
    }

    // MARK: - Load Theme Scriptures
    // Fetches this theme's Scripture pool from
    // the database.

    private func loadScriptures() async {

        isLoading = true
        errorMessage = nil

        do {

            scriptures =
                try await scriptureService
                    .fetchScriptures(
                        for: theme
                    )
        }

        catch {

            errorMessage =
                "HopeLine couldn't load these Scriptures. Check your internet connection and try again."
        }

        isLoading = false
    }
}

// MARK: - Theme Scripture Card
// One Scripture card inside the theme sheet.

private struct ThemeScriptureCard: View {

    let scripture: ThemeScripture

    // Whether this is the verse the user tapped.
    let isSelected: Bool

    // Called when the card is tapped.
    let onTap: () -> Void

    var body: some View {

        Button {
            onTap()
        } label: {

            VStack(
                alignment: .leading,
                spacing: 12
            ) {

                // MARK: Reference and Selection

                HStack {

                    Text(
                        scripture.verseReference
                    )
                    .font(.headline)
                    .foregroundStyle(.blue)

                    Spacer()

                    // Filled bookmark shown on the
                    // selected Scripture.
                    if isSelected {

                        Image(
                            systemName:
                                "bookmark.fill"
                        )
                        .foregroundStyle(.blue)
                    }
                }

                // MARK: Verse Text

                Text(
                    scripture.verseText
                )
                .font(.body)
                .multilineTextAlignment(.leading)
                .lineSpacing(4)
                .foregroundStyle(.primary)

                // MARK: Selection Caption

                if isSelected {

                    Text(
                        "You're holding onto this one today."
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                }
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .background(
                isSelected
                    ? Color.blue.opacity(0.08)
                    : Color(.secondarySystemBackground)
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16
                )
            )
            .overlay(
                // A subtle border on the selected card.
                RoundedRectangle(
                    cornerRadius: 16
                )
                .stroke(
                    isSelected
                        ? Color.blue.opacity(0.4)
                        : .clear,
                    lineWidth: 2
                )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {
        ScriptureView()
    }
}
