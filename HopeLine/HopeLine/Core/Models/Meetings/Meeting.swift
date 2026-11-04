//
//  Meeting.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import Foundation
import CoreLocation

struct Meeting: Codable, Identifiable, Hashable {

    // MARK: - Required Meeting Guide Fields

    let name: String
    let slug: String


    // MARK: - Time

    let day: MeetingDay?
    let time: String?
    let endTime: String?
    let timezone: String?


    // MARK: - Meeting Information

    let location: String?
    let group: String?
    let notes: String?
    let types: [String]?


    // MARK: - Address

    let formattedAddress: String?
    let address: String?
    let city: String?
    let state: String?
    let postalCode: String?
    let country: String?


    // MARK: - Geographic Location

    let latitude: Double?
    let longitude: Double?
    let approximate: String?


    // MARK: - Online Meeting

    let conferenceURL: String?
    let conferenceURLNotes: String?

    let conferencePhone: String?
    let conferencePhoneNotes: String?


    // MARK: - Additional Information

    let url: String?
    let updated: String?


    // MARK: - Identifiable

    var id: String {
        slug
    }


    // MARK: - Coding Keys

    enum CodingKeys: String, CodingKey {

        case name
        case slug

        case day
        case time

        case endTime = "end_time"

        case timezone

        case location
        case group
        case notes
        case types

        case formattedAddress = "formatted_address"

        case address
        case city
        case state

        case postalCode = "postal_code"

        case country

        case latitude
        case longitude
        case approximate

        case conferenceURL = "conference_url"

        case conferenceURLNotes =
            "conference_url_notes"

        case conferencePhone =
            "conference_phone"

        case conferencePhoneNotes =
            "conference_phone_notes"

        case url
        case updated
    }


    // MARK: - Meeting Type Helpers

    var isOnline: Bool {

        conferenceURL != nil ||
        conferencePhone != nil
    }


    var isInPerson: Bool {

        address != nil ||
        formattedAddress != nil
    }


    // MARK: - Map Coordinate

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


    // MARK: - Display Address

    var displayAddress: String {

        if let formattedAddress,
           !formattedAddress.isEmpty {

            return formattedAddress
        }

        let addressParts: [String?] = [
            address,
            city,
            state,
            postalCode
        ]

        let parts = addressParts
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        if parts.isEmpty {

            if isOnline {
                return "Online Meeting"
            }

            return "Location unavailable"
        }

        return parts.joined(
            separator: ", "
        )
    }


    // MARK: - Day Display

    var dayName: String {

        guard let day else {
            return "Day unavailable"
        }

        return day.displayName
    }


    // MARK: - Time Display

    var displayTime: String {

        guard let time,
              !time.isEmpty
        else {
            return "Time unavailable"
        }

        return Self.formatTime(time)
    }


    // MARK: - Time Formatter

    private static func formatTime(
        _ time: String
    ) -> String {

        let inputFormatter = DateFormatter()

        inputFormatter.locale =
            Locale(identifier: "en_US_POSIX")

        inputFormatter.dateFormat = "HH:mm"

        guard let date =
            inputFormatter.date(
                from: time
            )
        else {
            return time
        }

        let outputFormatter = DateFormatter()

        outputFormatter.timeStyle = .short

        return outputFormatter.string(
            from: date
        )
    }
}


// MARK: - Meeting Day

enum MeetingDay:
    Int,
    Codable,
    CaseIterable,
    Hashable {

    case sunday = 0
    case monday = 1
    case tuesday = 2
    case wednesday = 3
    case thursday = 4
    case friday = 5
    case saturday = 6


    var displayName: String {

        switch self {

        case .sunday:
            return "Sunday"

        case .monday:
            return "Monday"

        case .tuesday:
            return "Tuesday"

        case .wednesday:
            return "Wednesday"

        case .thursday:
            return "Thursday"

        case .friday:
            return "Friday"

        case .saturday:
            return "Saturday"
        }
    }
}
