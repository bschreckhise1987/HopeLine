//
//  MoodService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//

import Foundation
import Supabase

// Handles the daily check-in: reads the available moods and saves each
// check-in (category, notes, and selected moods) to Supabase.
final class MoodService {

    // MARK: - Properties

    // The shared Supabase client used for all mood and check-in queries.
    private let supabase = SupabaseManager.shared.client

    // MARK: - Fetch Moods

    // Loads every mood option, sorted by category then name so the
    // check-in UI can group them cleanly.
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

    // Saves one daily check-in: inserts the check-in row (category and
    // notes), then links each selected mood to it, and returns the saved
    // check-in so the UI can show a confirmation.
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

    // Links the user's selected moods to a check-in. Inserted in one
    // batch so the check-in and its moods save together.
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

    // Trims whitespace from optional notes and returns nil if nothing
    // meaningful was typed, so empty notes aren't saved to the database.
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

// The insert shape for a new check-in row. CodingKeys map to the
// database's snake_case column names.
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

// The insert shape linking one selected mood to a check-in.
private struct NewMoodSelection: Encodable {

    let checkInId: UUID
    let moodName: String

    enum CodingKeys: String, CodingKey {
        case checkInId = "checkin_id"
        case moodName = "mood_name"
    }
}
