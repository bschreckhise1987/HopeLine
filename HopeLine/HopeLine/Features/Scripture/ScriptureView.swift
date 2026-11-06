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

                    ScriptureCategoryRow(
                        emoji: "😰",
                        title: "Anxious or Afraid",
                        subtitle:
                            "Peace, refuge, and God's presence"
                    )

                    ScriptureCategoryRow(
                        emoji: "🛡️",
                        title: "Tempted or Craving",
                        subtitle:
                            "Strength, endurance, and a way through"
                    )

                    ScriptureCategoryRow(
                        emoji: "💔",
                        title: "Ashamed or Guilty",
                        subtitle:
                            "Grace, forgiveness, and restoration"
                    )

                    ScriptureCategoryRow(
                        emoji: "🫂",
                        title: "Lonely or Isolated",
                        subtitle:
                            "God's nearness and connection"
                    )

                    ScriptureCategoryRow(
                        emoji: "🌤️",
                        title: "Discouraged",
                        subtitle:
                            "Hope, perseverance, and courage"
                    )

                    ScriptureCategoryRow(
                        emoji: "🙏",
                        title: "Grateful",
                        subtitle:
                            "Praise and thanksgiving"
                    )
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

private struct ScriptureCategoryRow: View {

    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {

        Button {
            // Category Scripture
            // selection comes later.
        } label: {

            HStack(spacing: 14) {

                Text(emoji)
                    .font(.title2)

                VStack(
                    alignment: .leading,
                    spacing: 4
                ) {

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(
                            .primary
                        )

                    Text(subtitle)
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

// MARK: - Preview

#Preview {

    NavigationStack {
        ScriptureView()
    }
}
