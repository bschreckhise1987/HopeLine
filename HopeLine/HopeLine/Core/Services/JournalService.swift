//
//  JournalService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/3/26.
//

import Foundation
import Supabase


// MARK: - Journal Entry

// One journal entry from the journal_entries table. CodingKeys map
// Swift's camelCase properties to the database's snake_case columns.
struct JournalEntry: Codable, Identifiable {

    let id: UUID
    let userId: UUID
    let content: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case createdAt = "created_at"
    }
}


// MARK: - Journal Service

// Saves and loads the user's journal entries in Supabase. Accessed as
// JournalService.shared — use the singleton, never init one directly.
final class JournalService {

    static let shared = JournalService()

    private init() {}


    // MARK: - Journal Entry Insert Model

    // The shape sent to the database when creating a new entry. The
    // created_at column is filled in by the database, not the app.
    private struct JournalEntryInsert: Encodable {

        let userId: UUID
        let content: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case content
        }
    }


    // MARK: - Save Journal Entry

    // Saves a new journal entry for the signed-in user. Rejects empty
    // entries, then inserts into journal_entries. RLS on the table
    // guarantees the user can only write to their own rows.
    func saveEntry(content: String) async throws {

        let trimmedContent = content.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedContent.isEmpty else {
            throw JournalError.emptyEntry
        }

        let user = try await SupabaseManager.shared.client.auth.user()

        let entry = JournalEntryInsert(
            userId: user.id,
            content: trimmedContent
        )

        try await SupabaseManager.shared.client
            .from("journal_entries")
            .insert(entry)
            .execute()
    }


    // MARK: - Fetch Journal Entries

    // Loads the signed-in user's journal entries, newest first.
    // RLS on the table means each user only ever gets their own entries.
    func fetchEntries() async throws -> [JournalEntry] {

        let user = try await SupabaseManager.shared.client.auth.user()

        let entries: [JournalEntry] =
            try await SupabaseManager.shared.client
                .from("journal_entries")
                .select(
                    """
                    id,
                    user_id,
                    content,
                    created_at
                    """
                )
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

        return entries
    }
}


// MARK: - Journal Errors

// User-friendly errors the journal UI can show directly.
enum JournalError: LocalizedError {

    case emptyEntry

    var errorDescription: String? {

        switch self {

        case .emptyEntry:
            return "Your journal entry cannot be empty."
        }
    }
}
