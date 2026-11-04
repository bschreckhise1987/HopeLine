//
//  JournalService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/3/26.
//

import Foundation
import Supabase


// MARK: - Journal Entry

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

final class JournalService {

    static let shared = JournalService()

    private init() {}


    // MARK: - Journal Entry Insert Model

    private struct JournalEntryInsert: Encodable {

        let userId: UUID
        let content: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case content
        }
    }


    // MARK: - Save Journal Entry

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

enum JournalError: LocalizedError {

    case emptyEntry

    var errorDescription: String? {

        switch self {

        case .emptyEntry:
            return "Your journal entry cannot be empty."
        }
    }
}
