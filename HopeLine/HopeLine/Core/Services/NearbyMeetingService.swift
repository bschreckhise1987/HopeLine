//
//  NearbyMeetingService.swift
//  HopeLine
//
//  Created for the nationwide meeting finder feature.
//

import Foundation
import CoreLocation
import Supabase

// MARK: - Nearby Meeting Model

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

    // MARK: - Display Helpers

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

    var formattedDistance: String? {

        guard let distanceMiles
        else {
            return nil
        }

        return
            String(format: "%.1f mi away", distanceMiles)
    }

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

private struct NearbyMeetingsParams: Encodable {

    let lat: Double
    let lng: Double
    let radiusMiles: Double

    enum CodingKeys: String, CodingKey {

        case lat
        case lng
        case radiusMiles = "radius_miles"
    }
}

// MARK: - Nearby Meeting Service

final class NearbyMeetingService {

    static let shared = NearbyMeetingService()

    private init() {}

    // MARK: - Fetch Nearby Meetings

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

        let meetings: [NearbyMeeting] =
            try await SupabaseManager.shared.client.database
            .rpc(
                "nearby_meetings",
                params: params
            )
            .execute()
            .value

        return meetings
    }

    // MARK: - Fetch With Automatic Widening

    // Tries the requested radius first, then widens it
    // until meetings are found or the largest radius is reached.

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
