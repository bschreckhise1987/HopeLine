//
//  HomeView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

struct HomeView: View {

    // MARK: - State

    // Today's Scripture shown in the Home card.
    @State private var dailyScripture: DailyScripture?

    // Uses the shared service instance — ScriptureService
    // has a private initializer (singleton pattern).
    private let scriptureService = ScriptureService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Welcome

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome to HopeLine")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Take today one step at a time.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // MARK: - Daily Check-In

                    VStack(alignment: .leading, spacing: 12) {
                        Text("How are you doing today?")
                            .font(.title2)
                            .fontWeight(.semibold)

                        NavigationLink {
                            CheckInView()
                        } label: {
                            Label(
                                "Daily Check-In",
                                systemImage: "heart.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }

                    // MARK: - HopeLine Features

                    Text("Your HopeLine")
                        .font(.title2)
                        .fontWeight(.semibold)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        spacing: 16
                    ) {

                        // MARK: Journal

                        NavigationLink {
                            JournalView()
                        } label: {
                            HomeFeatureCard(
                                title: "Journal",
                                subtitle: "Write and reflect",
                                icon: "book.closed.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        // MARK: Prayer

                        NavigationLink {
                            PrayerView()
                        } label: {
                            HomeFeatureCard(
                                title: "Prayer",
                                subtitle: "Prayer requests",
                                icon: "hands.sparkles.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        // MARK: Meetings

                        NavigationLink {
                            MeetingsView()
                        } label: {
                            HomeFeatureCard(
                                title: "Meetings",
                                subtitle: "Find support",
                                icon: "person.3.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        // MARK: Progress

                        HomeFeatureCard(
                            title: "Progress",
                            subtitle: "See your journey",
                            icon: "chart.line.uptrend.xyaxis"
                        )
                    }

                    // MARK: - Daily Scripture

                    // Live card showing today's Scripture.
                    // Tapping opens the full Scripture screen.

                    NavigationLink {
                        ScriptureView()
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Label(
                                "Daily Scripture",
                                systemImage: "cross.fill"
                            )
                            .font(.headline)

                            if let scripture = dailyScripture {

                                // A short preview of today's verse.
                                Text(
                                    scripture.verseText
                                )
                                .font(.body)
                                .lineLimit(3)
                                .foregroundStyle(.secondary)

                                Text(
                                    scripture.verseReference
                                )
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                            } else {

                                // Shown while today's
                                // Scripture loads.
                                Text(
                                    "Tap to read today's Scripture."
                                )
                                .font(.body)
                                .foregroundStyle(.secondary)
                            }
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
                    }
                    .buttonStyle(.plain)

                    // MARK: - Help

                    Button {
                        // Help navigation will go here later
                    } label: {
                        Label(
                            "I Need Help",
                            systemImage: "lifepreserver.fill"
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationTitle("HopeLine")
            .task {
                // Loads today's Scripture when
                // the Home screen first appears.
                await loadDailyScripture()
            }
            .toolbar {

                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    NavigationLink {
                        SettingsView()                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                        .accessibilityLabel("Settings")
                }
            }
        }
    }

    // MARK: - Load Daily Scripture
    // Fetches today's Scripture for the Home card.
    // Failures are silent here — the card simply shows
    // its fallback text instead of blocking the Home screen.

    private func loadDailyScripture() async {

        dailyScripture =
            try? await scriptureService
                .fetchDailyScripture()
    }
}


// MARK: - Home Feature Card

private struct HomeFeatureCard: View {

    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)

            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            minHeight: 110,
            alignment: .leading
        )
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}
