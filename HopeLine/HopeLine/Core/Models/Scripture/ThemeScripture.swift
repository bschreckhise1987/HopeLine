//
//  ThemeScripture.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/6/26.
//

import Foundation

// MARK: - Theme Scripture
// One Scripture from the `scripture_references` table,
// linked to a recovery theme (anxious, tempted, etc.).

struct ThemeScripture: Codable, Identifiable, Hashable {

    let id: UUID
    let theme: String
    let verseReference: String
    let verseText: String
    let sortOrder: Int?

    // Maps the database's snake_case column names
    // (verse_reference, verse_text, ...) to Swift's
    // camelCase property names above.
    enum CodingKeys: String, CodingKey {

        case id
        case theme
        case verseReference = "verse_reference"
        case verseText = "verse_text"
        case sortOrder = "sort_order"
    }
}

// MARK: - Scripture Theme
// The six recovery themes shown in the Scripture screen.
// The themes are part of the UI; the verses behind each
// theme live in the database and can grow without an
// app update.

enum ScriptureTheme:
    String,
    CaseIterable,
    Identifiable {

    case anxious
    case tempted
    case ashamed
    case lonely
    case discouraged
    case grateful

    var id: String {
        rawValue
    }

    // The title shown on the category row.
    var title: String {

        switch self {

        case .anxious:
            return "Anxious or Afraid"

        case .tempted:
            return "Tempted or Craving"

        case .ashamed:
            return "Ashamed or Guilty"

        case .lonely:
            return "Lonely or Isolated"

        case .discouraged:
            return "Discouraged"

        case .grateful:
            return "Grateful"
        }
    }

    // The emoji shown on the category row.
    var emoji: String {

        switch self {

        case .anxious:
            return "😰"

        case .tempted:
            return "🛡️"

        case .ashamed:
            return "💔"

        case .lonely:
            return "🫂"

        case .discouraged:
            return "🌤️"

        case .grateful:
            return "🙏"
        }
    }

    // The short description shown on the category row.
    var subtitle: String {

        switch self {

        case .anxious:
            return "Peace, refuge, and God's presence"

        case .tempted:
            return "Strength, endurance, and a way through"

        case .ashamed:
            return "Grace, forgiveness, and restoration"

        case .lonely:
            return "God's nearness and connection"

        case .discouraged:
            return "Hope, perseverance, and courage"

        case .grateful:
            return "Praise and thanksgiving"
        }
    }
}
