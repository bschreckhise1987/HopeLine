//
//  CheckInView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

struct CheckInView: View {

    // MARK: - Properties

    @State private var selectedMood: MoodOption?
    @State private var intensity = 5.0
    @State private var note = ""

    private let moods: [MoodOption] = [
        MoodOption(name: "Great", icon: "sun.max.fill", color: .yellow),
        MoodOption(name: "Good", icon: "face.smiling.fill", color: .green),
        MoodOption(name: "Okay", icon: "cloud.sun.fill", color: .blue),
        MoodOption(name: "Struggling", icon: "cloud.fill", color: .orange),
        MoodOption(name: "Overwhelmed", icon: "cloud.rain.fill", color: .red)
    ]

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Introduction

                VStack(alignment: .leading, spacing: 6) {
                    Text("How are you doing today?")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Take a moment to check in with yourself.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // MARK: - Mood

                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose your mood")
                        .font(.title2)
                        .fontWeight(.semibold)

                    ForEach(moods) { mood in
                        Button {
                            selectedMood = mood
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: mood.icon)
                                    .font(.title2)
                                    .foregroundStyle(mood.color)
                                    .frame(width: 32)

                                Text(mood.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(
                                    systemName: selectedMood?.id == mood.id
                                        ? "checkmark.circle.fill"
                                        : "circle"
                                )
                                .font(.title3)
                                .foregroundStyle(
                                    selectedMood?.id == mood.id
                                        ? Color.blue
                                        : Color.secondary
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
                        .buttonStyle(.plain)
                    }
                }

                // MARK: - Intensity

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("How strong is this feeling?")
                            .font(.headline)

                        Spacer()

                        Text("\(Int(intensity))/10")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }

                    Slider(
                        value: $intensity,
                        in: 1...10,
                        step: 1
                    )

                    HStack {
                        Text("Mild")
                        Spacer()
                        Text("Very Strong")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                // MARK: - Reflection

                VStack(alignment: .leading, spacing: 12) {
                    Text("What's on your mind?")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("You can add a note if you want to.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.systemBackground))
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

                // MARK: - Save

                Button {
                    // Saving to MoodService will be connected next
                } label: {
                    Label(
                        "Save Check-In",
                        systemImage: "heart.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(selectedMood == nil)

                Text(
                    "Your check-ins can help you recognize patterns throughout your recovery journey."
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .navigationTitle("Daily Check-In")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Mood Option

private struct MoodOption: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CheckInView()
    }
}
