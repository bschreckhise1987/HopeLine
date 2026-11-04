//
//  MeetingService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import Foundation


// MARK: - Meeting Service

final class MeetingService {

    static let shared = MeetingService()

    private init() {}


    // MARK: - Fetch Meetings

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

    func inPersonMeetings(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.isInPerson
        }
    }


    // MARK: - Online Meetings

    func onlineMeetings(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.isOnline
        }
    }


    // MARK: - Meetings With Map Coordinates

    func meetingsWithCoordinates(
        from meetings: [Meeting]
    ) -> [Meeting] {

        meetings.filter { meeting in
            meeting.coordinate != nil
        }
    }
}


// MARK: - Meeting Service Error

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
