//
//  DailyScripture.swift
//  HopeLine
//
//  One curated daily Scripture from the `daily_scriptures`
//  table — the verse, its reference, a short prayer, and a
//  reflection prompt for the user's day.
//

import Foundation

struct DailyScripture: Codable, Identifiable, Hashable {

    let id: UUID
    let verseReference: String
    let verseText: String
    let prayer: String?
    let reflectionPrompt: String?
    let createdAt: Date?

    // Maps the database's snake_case column names
    // (verse_reference, verse_text, ...) to Swift's
    // camelCase property names above.
    enum CodingKeys: String, CodingKey {

        case id
        case verseReference = "verse_reference"
        case verseText = "verse_text"
        case prayer
        case reflectionPrompt = "reflection_prompt"
        case createdAt = "created_at"
    }
}
