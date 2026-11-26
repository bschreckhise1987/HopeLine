//
//  MeetingFavoriteService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/25/26.
//

import Foundation
import Supabase

// Handles each user's favorite meetings: saving, removing,
// and fetching the meeting guide IDs they've favorited.
// A favorite stores the meeting's stable guide ID so it
// survives the weekly meeting data syncs.
final class MeetingFavoriteService {

    // MARK: - Properties

    // The shared Supabase client used for all favorite queries.
    private let supabase = SupabaseManager.shared.client

    // The shared service instance (singleton pattern).
    static let shared = MeetingFavoriteService()

    // Private so only the shared instance exists.
    private init() {}

    // MARK: - Fetch Favorites

    // Returns the meeting guide IDs the signed-in user has
    // favorited, so the list and detail screens can mark them.
    func fetchFavoriteGuideIds() async throws -> Set<String> {

        let user =
            try await supabase.auth.user()

        let favorites: [MeetingFavorite] = try await supabase
            .from("favorite_meetings")
            .select()
            .eq(
                "user_id",
                value: user.id
            )
            .execute()
            .value

        return Set(
            favorites.map(
                \.meetingGuideId
            )
        )
    }

    // MARK: - Favorite a Meeting

    // Saves one favorite for the signed-in user.
    func favoriteMeeting(
        guideId: String
    ) async throws {

        let user =
            try await supabase.auth.user()

        struct FavoriteInsert: Encodable {

            let userId: UUID
            let meetingGuideId: String

            enum CodingKeys: String, CodingKey {

                case userId = "user_id"
                case meetingGuideId = "meeting_guide_id"
            }
        }

        let favorite = FavoriteInsert(
            userId: user.id,
            meetingGuideId: guideId
        )

        try await supabase
            .from("favorite_meetings")
            .insert(favorite)
            .execute()
    }

    // MARK: - Unfavorite a Meeting

    // Removes one favorite for the signed-in user.
    func unfavoriteMeeting(
        guideId: String
    ) async throws {

        let user =
            try await supabase.auth.user()

        try await supabase
            .from("favorite_meetings")
            .delete()
            .eq(
                "user_id",
                value: user.id
            )
            .eq(
                "meeting_guide_id",
                value: guideId
            )
            .execute()
    }
}

// MARK: - Meeting Favorite

// One row from the favorite_meetings table. CodingKeys map
// Swift's camelCase properties to the database's snake_case
// column names.
struct MeetingFavorite: Codable, Identifiable, Hashable {

    let id: UUID
    let userId: UUID
    let meetingGuideId: String
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {

        case id
        case userId = "user_id"
        case meetingGuideId = "meeting_guide_id"
        case createdAt = "created_at"
    }
}
