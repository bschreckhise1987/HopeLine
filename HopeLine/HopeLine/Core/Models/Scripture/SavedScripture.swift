//
//  SavedScripture.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/6/26.
//

import Foundation

// MARK: - Saved Scripture
// One verse the user saved, stored in the
// `saved_scriptures` table (private per user).

struct SavedScripture: Codable, Identifiable, Hashable {

    let id: UUID
    let userId: UUID
    let verseReference: String
    let verseText: String
    let createdAt: Date?

    // Maps the database's snake_case column names
    // (verse_reference, verse_text, ...) to Swift's
    // camelCase property names above.
    enum CodingKeys: String, CodingKey {

        case id
        case userId = "user_id"
        case verseReference = "verse_reference"
        case verseText = "verse_text"
        case createdAt = "created_at"
    }
}
