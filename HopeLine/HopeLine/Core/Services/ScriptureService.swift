//
//  ScriptureService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/6/26.
//
//  Loads the daily Scripture from Supabase and records
//  when a user views one. Built so a future AI
//  recommendation layer can be added without changing
//  how the app reads Scriptures.
//

import Foundation
import Supabase

final class ScriptureService {

    static let shared = ScriptureService()

    // The Supabase client every other service uses.
    private let supabase = SupabaseManager.shared.client

    private init() {}

    // MARK: - Fetch Daily Scripture
    // Picks one Scripture for today using a day-of-year
    // rotation: everyone sees the same verse, it stays the
    // same all day, and it changes at midnight. No date
    // column needed in the database.

    func fetchDailyScripture() async throws -> DailyScripture {

        let scriptures: [DailyScripture] =
            try await supabase
            .from("daily_scriptures")
            .select()
            .order(
                "created_at",
                ascending: true
            )
            .execute()
            .value

        guard !scriptures.isEmpty else {
            throw ScriptureError.noScriptures
        }

        let dayOfYear =
            Calendar.current.ordinality(
                of: .day,
                in: .year,
                for: Date()
            ) ?? 1

        let index =
            (dayOfYear - 1) % scriptures.count

        return scriptures[index]
    }

    // MARK: - Fetch All Scriptures
    // Returns the full pool. Used later by theme
    // exploration and future recommendations.

    func fetchAllScriptures() async throws -> [DailyScripture] {

        let scriptures: [DailyScripture] =
            try await supabase
            .from("daily_scriptures")
            .select()
            .order(
                "created_at",
                ascending: true
            )
            .execute()
            .value

        return scriptures
    }

    // MARK: - Fetch Scriptures by Theme
    // Gets the Scripture pool for one recovery theme
    // (anxious, tempted, etc.) from the scripture_references
    // table. The verses come back in the database's
    // sort_order.

    func fetchScriptures(
        for theme: ScriptureTheme
    ) async throws -> [ThemeScripture] {

        let scriptures: [ThemeScripture] =
            try await supabase
            .from("scripture_references")
            .select()
            .eq(
                "theme",
                value: theme.rawValue
            )
            .order(
                "sort_order",
                ascending: true
            )
            .execute()
            .value

        return scriptures
    }

    // MARK: - Save Scripture
    // Saves a verse to the user's saved Scriptures.
    // Throws when the user isn't signed in.

    func saveScripture(
        reference: String,
        text: String
    ) async throws {

        let user =
            try await supabase.auth.user()

        struct SavedInsert: Encodable {

            let userId: UUID
            let verseReference: String
            let verseText: String

            enum CodingKeys: String, CodingKey {

                case userId = "user_id"
                case verseReference = "verse_reference"
                case verseText = "verse_text"
            }
        }

        let saved = SavedInsert(
            userId: user.id,
            verseReference: reference,
            verseText: text
        )

        try await supabase
            .from("saved_scriptures")
            .insert(saved)
            .execute()
    }

    // MARK: - Remove Saved Scripture
    // Un-saves a verse for the signed-in user.

    func removeSavedScripture(
        reference: String
    ) async throws {

        let user =
            try await supabase.auth.user()

        try await supabase
            .from("saved_scriptures")
            .delete()
            .eq(
                "user_id",
                value: user.id
            )
            .eq(
                "verse_reference",
                value: reference
            )
            .execute()
    }

    // MARK: - Check if Scripture is Saved
    // Returns whether the signed-in user has already
    // saved this verse. Returns false when the user
    // isn't signed in — saving just isn't offered yet.

    func isScriptureSaved(
        reference: String
    ) async -> Bool {

        guard
            let userId =
                try? await supabase.auth.user().id
        else {
            return false
        }

        let saved: [SavedScripture] =
            (try? await supabase
                .from("saved_scriptures")
                .select()
                .eq(
                    "user_id",
                    value: userId
                )
                .eq(
                    "verse_reference",
                    value: reference
                )
                .execute()
                .value) ?? []

        return !saved.isEmpty
    }

    // MARK: - Fetch Saved Scriptures
    // Returns everything the signed-in user has saved,
    // newest first.

    func fetchSavedScriptures() async throws -> [SavedScripture] {

        let user =
            try await supabase.auth.user()

        let saved: [SavedScripture] =
            try await supabase
            .from("saved_scriptures")
            .select()
            .eq(
                "user_id",
                value: user.id
            )
            .order(
                "created_at",
                ascending: false
            )
            .execute()
            .value

        return saved
    }

    // MARK: - Record Scripture View
    // Saves a row to `scripture_activity` when the user
    // opens a Scripture, so HopeLine can eventually show
    // which Scriptures a person has reflected on. Silently
    // does nothing when the user isn't signed in — viewing
    // Scripture should never require an account.

    func recordView(scriptureId: UUID) async {

        guard
            let userId =
                try? await supabase.auth.user().id
        else {
            return
        }

        struct ActivityInsert: Encodable {

            let userId: UUID
            let scriptureId: UUID

            enum CodingKeys: String, CodingKey {

                case userId = "user_id"
                case scriptureId = "scripture_id"
            }
        }

        let activity = ActivityInsert(
            userId: userId,
            scriptureId: scriptureId
        )

        // A failed activity log should never block or
        // interrupt the user's Scripture experience.
        _ = try? await supabase
            .from("scripture_activity")
            .insert(activity)
            .execute()
    }
}

// MARK: - Scripture Errors
// Errors the Scripture feature can show to the user.

enum ScriptureError: LocalizedError {

    // The daily_scriptures table has no rows yet.
    case noScriptures

    var errorDescription: String? {

        switch self {

        case .noScriptures:
            return
                "No Scriptures are available yet. " +
                "Please check back soon."
        }
    }
}
