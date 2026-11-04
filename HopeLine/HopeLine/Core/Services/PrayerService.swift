//
//  PrayerService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/3/26.
//

import Foundation
import Supabase


// MARK: - Prayer Request

struct PrayerRequest: Codable, Identifiable {

    let id: UUID
    let userId: UUID
    let requestText: String
    let isAnswered: Bool
    let answeredNote: String?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case requestText = "request_text"
        case isAnswered = "is_answered"
        case answeredNote = "answered_note"
        case createdAt = "created_at"
    }
}


// MARK: - Prayer Response

struct PrayerResponse: Codable, Identifiable {

    let id: UUID
    let prayerRequestId: UUID
    let userId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case prayerRequestId = "prayer_request_id"
        case userId = "user_id"
        case createdAt = "created_at"
    }
}


// MARK: - Community Prayer

struct CommunityPrayer: Identifiable {

    let prayer: PrayerRequest
    let prayerCount: Int
    let hasPrayed: Bool

    var id: UUID {
        prayer.id
    }
}

// MARK: - Prayer Answer Update Model

private struct PrayerAnswerUpdate: Encodable {

    let isAnswered: Bool
    let answeredNote: String?

    enum CodingKeys: String, CodingKey {
        case isAnswered = "is_answered"
        case answeredNote = "answered_note"
    }
}


// MARK: - Prayer Service

final class PrayerService {

    static let shared = PrayerService()

    private init() {}


    // MARK: - Prayer Request Insert Model

    private struct PrayerRequestInsert: Encodable {

        let userId: UUID
        let requestText: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case requestText = "request_text"
        }
    }


    // MARK: - Prayer Response Insert Model

    private struct PrayerResponseInsert: Encodable {

        let prayerRequestId: UUID
        let userId: UUID

        enum CodingKeys: String, CodingKey {
            case prayerRequestId = "prayer_request_id"
            case userId = "user_id"
        }
    }


    // MARK: - Share Prayer Request

    func sharePrayer(
        requestText: String
    ) async throws {

        let trimmedText = requestText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedText.isEmpty else {
            throw PrayerError.emptyRequest
        }

        let user = try await SupabaseManager.shared.client
            .auth
            .user()

        let request = PrayerRequestInsert(
            userId: user.id,
            requestText: trimmedText
        )

        try await SupabaseManager.shared.client
            .from("prayer_requests")
            .insert(request)
            .execute()
    }


    // MARK: - Fetch Community Prayers

    func fetchCommunityPrayers() async throws -> [CommunityPrayer] {

        let currentUser = try await SupabaseManager.shared.client
            .auth
            .user()

        let requests: [PrayerRequest] =
            try await SupabaseManager.shared.client
                .from("prayer_requests")
                .select(
                    """
                    id,
                    user_id,
                    request_text,
                    is_answered,
                    answered_note,
                    created_at
                    """
                )
                .order(
                    "created_at",
                    ascending: false
                )
                .execute()
                .value

        let responses: [PrayerResponse] =
            try await SupabaseManager.shared.client
                .from("prayer_responses")
                .select(
                    """
                    id,
                    prayer_request_id,
                    user_id,
                    created_at
                    """
                )
                .execute()
                .value

        return requests.map { request in

            let requestResponses = responses.filter {
                $0.prayerRequestId == request.id
            }

            let hasPrayed = requestResponses.contains {
                $0.userId == currentUser.id
            }

            return CommunityPrayer(
                prayer: request,
                prayerCount: requestResponses.count,
                hasPrayed: hasPrayed
            )
        }
    }


    // MARK: - Fetch My Prayer Requests

    func fetchMyPrayers() async throws -> [CommunityPrayer] {

        let currentUser = try await SupabaseManager.shared.client
            .auth
            .user()

        let requests: [PrayerRequest] =
            try await SupabaseManager.shared.client
                .from("prayer_requests")
                .select(
                    """
                    id,
                    user_id,
                    request_text,
                    is_answered,
                    answered_note,
                    created_at
                    """
                )
                .eq(
                    "user_id",
                    value: currentUser.id
                )
                .order(
                    "created_at",
                    ascending: false
                )
                .execute()
                .value

        let responses: [PrayerResponse] =
            try await SupabaseManager.shared.client
                .from("prayer_responses")
                .select(
                    """
                    id,
                    prayer_request_id,
                    user_id,
                    created_at
                    """
                )
                .execute()
                .value

        return requests.map { request in

            let requestResponses = responses.filter {
                $0.prayerRequestId == request.id
            }

            let hasPrayed = requestResponses.contains {
                $0.userId == currentUser.id
            }

            return CommunityPrayer(
                prayer: request,
                prayerCount: requestResponses.count,
                hasPrayed: hasPrayed
            )
        }
    }


    // MARK: - Pray For Request

    func prayForRequest(
        prayerRequestId: UUID
    ) async throws {

        let user = try await SupabaseManager.shared.client
            .auth
            .user()

        let response = PrayerResponseInsert(
            prayerRequestId: prayerRequestId,
            userId: user.id
        )

        try await SupabaseManager.shared.client
            .from("prayer_responses")
            .insert(response)
            .execute()
    }


    // MARK: - Mark Prayer as Answered

    func markAsAnswered(
        prayerRequestId: UUID,
        answeredNote: String?
    ) async throws {

        let user = try await SupabaseManager.shared.client
            .auth
            .user()

        let trimmedNote = answeredNote?
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        let update = PrayerAnswerUpdate(
            isAnswered: true,
            answeredNote: trimmedNote?.isEmpty == true
                ? nil
                : trimmedNote
        )

        try await SupabaseManager.shared.client
            .from("prayer_requests")
            .update(update)
            .eq(
                "id",
                value: prayerRequestId
            )
            .eq(
                "user_id",
                value: user.id
            )
            .execute()
    }
}


// MARK: - Prayer Errors

enum PrayerError: LocalizedError {

    case emptyRequest

    var errorDescription: String? {

        switch self {

        case .emptyRequest:
            return "Your prayer request cannot be empty."
        }
    }
}
