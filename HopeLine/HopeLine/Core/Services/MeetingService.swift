//
//  MeetingService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import Foundation


// MARK: - Meeting Service

// Loads meeting feeds from BMLT servers in the open Meeting Guide JSON
// format and provides local filtering helpers (search, in-person,
// online, mappable). The live Meetings screen mostly uses
// NearbyMeetingService + Supabase now; this service handles raw feed
// fetching and client-side filtering.
final class MeetingService {

    static let shared = MeetingService()

    private init() {}


    // MARK: - Fetch Meetings

    // Downloads and decodes a meeting feed from a BMLT server. Skips the
    // cache so the data is always fresh, times out after 30 seconds,
    // and gives each failure mode its own error.
    func fetchMeetings(
        from feedURL: URL
    ) async throws -> [Meeting] {

        let request = URLRequest(
            url: feedURL,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )

        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw MeetingServiceError.invalidResponse
        }

        guard (200...299).contains(
            httpResponse.statusCode
        )
        else {
            throw MeetingServiceError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        do {

            let decoder = JSONDecoder()

            let meetings = try decoder.decode(
                [Meeting].self,
                from: data
            )

            return meetings

        } catch {

            throw MeetingServiceError.decodingFailed(
                underlyingError: error
            )
        }
    }


    // MARK: - Search Meetings

    // Case-insensitive search across name, location, city, state, zip
    // code, and group. Empty search text returns everything.
    func searchMeetings(
        _ meetings: [Meeting],
        searchText: String
    ) -> [Meeting] {

        let trimmedSearch =
            searchText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

        guard !trimmedSearch.isEmpty else {
            return meetings
        }

        return meetings.filter { meeting in

            meeting.name
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                )

            ||

            meeting.location?
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                ) == true

            ||

            meeting.city?
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                ) == true

            ||

            meeting.state?
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                ) == true

            ||

            meeting.postalCode?
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                ) == true

            ||

            meeting.group?
                .localizedCaseInsensitiveContains(
                    trimmedSearch
                ) == true
        }
    }


    // MARK: - In-Person Meetings

    // Only meetings that happen at a physical location.
    func inPersonMeetings(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.isInPerson
        }
    }


    // MARK: - Online Meetings

    // Only meetings that happen online (video/phone).
    func onlineMeetings(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.isOnline
        }
    }


    // MARK: - Meetings With Map Coordinates

    // Only meetings that have latitude/longitude, so they can be pinned
    // on the map.
    func meetingsWithCoordinates(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.coordinate != nil
        }
    }
}


// MARK: - Meeting Service Error

// User-friendly errors for every way a meeting feed can fail.
enum MeetingServiceError: LocalizedError {

    case invalidResponse

    case httpError(
        statusCode: Int
    )

    case decodingFailed(
        underlyingError: Error
    )


    var errorDescription: String? {

        switch self {

        case .invalidResponse:

            return
                "HopeLine received an invalid response while loading meetings."


        case .httpError(let statusCode):

            return
                "The meeting service returned an error. HTTP status code: \(statusCode)."


        case .decodingFailed(let error):

            return
                "HopeLine couldn't read the meeting data. \(error.localizedDescription)"
        }
    }
}
