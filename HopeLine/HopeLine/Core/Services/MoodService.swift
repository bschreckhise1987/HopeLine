//
//  MoodService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//

import Foundation
import Supabase

final class MoodService {

    // MARK: - Properties

    private let supabase = SupabaseManager.shared.client

    // MARK: - Fetch Moods

    func fetchMoods() async throws -> [Mood] {
        let moods: [Mood] = try await supabase
            .from("moods")
            .select()
            .execute()
            .value

        return moods.sorted {
            if $0.category == $1.category {
                return $0.name < $1.name
            }

            return $0.category < $1.category
        }
    }

    // MARK: - Create Check-In

    func createCheckIn(
        userId: UUID,
        category: String,
        notes: String?,
        selectedMoods: [Mood]
    ) async throws -> MoodCheckIn {

        let newCheckIn = NewMoodCheckIn(
            userId: userId,
            category: category,
            notes: cleanedNotes(notes)
        )

        let checkIn: MoodCheckIn = try await supabase
            .from("mood_checkins")
            .insert(newCheckIn)
            .select()
            .single()
            .execute()
            .value

        try await saveMoodSelections(
            checkInId: checkIn.id,
            moods: selectedMoods
        )

        return checkIn
    }

    // MARK: - Save Mood Selections

    private func saveMoodSelections(
        checkInId: UUID,
        moods: [Mood]
    ) async throws {

        guard !moods.isEmpty else {
            return
        }

        let selections = moods.map { mood in
            NewMoodSelection(
                checkInId: checkInId,
                moodName: mood.name
            )
        }

        try await supabase
            .from("mood_selections")
            .insert(selections)
            .execute()
    }

    // MARK: - Helpers

    private func cleanedNotes(
        _ notes: String?
    ) -> String? {

        guard let notes else {
            return nil
        }

        let trimmedNotes = notes.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return trimmedNotes.isEmpty
            ? nil
            : trimmedNotes
    }
}

// MARK: - New Mood Check-In

private struct NewMoodCheckIn: Encodable {

    let userId: UUID
    let category: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case category
        case notes
    }
}

// MARK: - New Mood Selection

private struct NewMoodSelection: Encodable {

    let checkInId: UUID
    let moodName: String

    enum CodingKeys: String, CodingKey {
        case checkInId = "checkin_id"
        case moodName = "mood_name"
    }
}
