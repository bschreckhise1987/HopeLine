//
//  NearbyMeetingService.swift
//  HopeLine
//
//  Fetches real meetings near the user's current location
//  from the Supabase `meetings` table via the
//  `nearby_meetings` database function.
//

import Foundation
import CoreLocation
import Supabase

// MARK: - Nearby Meeting Model
// One recovery meeting returned by the database,
// including how far away it is from the user.

struct NearbyMeeting: Codable, Identifiable, Hashable {

    let id: UUID
    let meetingGuideID: String?
    let name: String
    let meetingType: String?
    let meetingDay: String?
    let meetingTime: String?
    let endTime: String?
    let address: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let latitude: Double?
    let longitude: Double?
    let isOnline: Bool
    let onlineURL: String?
    let distanceMiles: Double?

    // Maps the database's snake_case column names
    // (meeting_guide_id, is_online, ...) to Swift's
    // camelCase property names above.
    enum CodingKeys: String, CodingKey {

        case id
        case meetingGuideID = "meeting_guide_id"
        case name
        case meetingType = "meeting_type"
        case meetingDay = "meeting_day"
        case meetingTime = "meeting_time"
        case endTime = "end_time"
        case address
        case city
        case state
        case postalCode = "postal_code"
        case latitude
        case longitude
        case isOnline = "is_online"
        case onlineURL = "online_url"
        case distanceMiles = "distance_miles"
    }

    // MARK: - Display Helpers

    // Turns "19:30" into "7:30 PM" for the meeting card.
    var formattedTime: String? {

        guard let meetingTime,
              !meetingTime.isEmpty
        else {
            return nil
        }

        let components =
            meetingTime.split(separator: ":")

        guard
            components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return meetingTime
        }

        let isPM = hour >= 12
        let displayHour = hour % 12 == 0 ? 12 : hour % 12

        return
            "\(displayHour):\(String(format: "%02d", minute)) \(isPM ? "PM" : "AM")"
    }

    // Turns 0.18511... into "0.2 mi away" for the meeting card.
    var formattedDistance: String? {

        guard let distanceMiles
        else {
            return nil
        }

        return
            String(format: "%.1f mi away", distanceMiles)
    }

    // The map coordinate for this meeting, if the
    // database has one on file.
    var coordinate: CLLocationCoordinate2D? {

        guard
            let latitude,
            let longitude
        else {
            return nil
        }

        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

// MARK: - RPC Parameters
// The values sent to the database function:
// the user's location and how far out to search.

private struct NearbyMeetingsParams: Encodable {

    let lat: Double
    let lng: Double
    let radiusMiles: Double

    // Uses snake_case keys so the database function
    // receives the argument names it expects.
    enum CodingKeys: String, CodingKey {

        case lat
        case lng
        case radiusMiles = "radius_miles"
    }
}

// MARK: - Nearby Meeting Service
// Calls Supabase to get meetings near a location.

final class NearbyMeetingService {

    static let shared = NearbyMeetingService()

    private init() {}

    // MARK: - Fetch Nearby Meetings
    // Gets all meetings within the given radius of the
    // user's coordinates, already sorted by distance
    // (closest first) by the database.

    func fetchNearbyMeetings(
        latitude: Double,
        longitude: Double,
        radiusMiles: Double = 10
    ) async throws -> [NearbyMeeting] {

        let params = NearbyMeetingsParams(
            lat: latitude,
            lng: longitude,
            radiusMiles: radiusMiles
        )

        // Calls the database function through the
        // current (non-deprecated) client method.
        let meetings: [NearbyMeeting] =
            try await SupabaseManager.shared.client
            .rpc(
                "nearby_meetings",
                params: params
            )
            .execute()
            .value

        return meetings
    }

    // MARK: - Fetch With Automatic Widening
    // Tries the starting radius first. If nothing is
    // found (rural areas), widens the search step by
    // step up to 100 miles before giving up.

    func fetchNearbyMeetingsWithWidening(
        latitude: Double,
        longitude: Double,
        startingRadiusMiles: Double = 10
    ) async throws -> [NearbyMeeting] {

        let radii: [Double] =
            [startingRadiusMiles, 25, 50, 100]

        for radius in radii {

            let meetings = try await fetchNearbyMeetings(
                latitude: latitude,
                longitude: longitude,
                radiusMiles: radius
            )

            if !meetings.isEmpty {
                return meetings
            }
        }

        return []
    }
}
