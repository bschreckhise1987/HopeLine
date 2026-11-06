//
//  MeetingsView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import SwiftUI
import MapKit
import CoreLocation

struct MeetingsView: View {

    @StateObject private var locationService = LocationService()
    @State private var searchText = ""
    @State private var selectedFilter: MeetingFilter = .all

    @State private var mapPosition: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)

    // MARK: - Live Meeting State

    @State private var nearbyMeetings: [NearbyMeeting] = []
    @State private var isLoadingMeetings = false
    @State private var meetingsErrorMessage: String?

    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: - Header

                VStack(alignment: .leading, spacing: 8) {

                    Text("👥 Recovery Meetings")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(
                        "Find support, connection, and a place to keep showing up."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Search

                HStack(spacing: 12) {

                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        "Search meetings or locations",
                        text: $searchText
                    )

                    if !searchText.isEmpty {

                        Button {
                            searchText = ""
                        } label: {

                            Image(
                                systemName: "xmark.circle.fill"
                            )
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                // MARK: - Filters

                Picker(
                    "Meeting Type",
                    selection: $selectedFilter
                ) {
                    ForEach(MeetingFilter.allCases) { filter in

                        Text(filter.title)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)

                // MARK: - Encouragement

                VStack(alignment: .leading, spacing: 10) {

                    Label(
                        "You Don't Have to Do This Alone",
                        systemImage: "heart.fill"
                    )
                    .font(.headline)

                    Text(
                        "Connection is an important part of recovery. Find a meeting that works for you and take the next step."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )

                // MARK: - Map

                VStack(alignment: .leading, spacing: 12) {

                    HStack {

                        Text("Find Meetings Near You")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Image(systemName: "location.fill")
                            .foregroundStyle(.blue)
                    }

                    Map(position: $mapPosition) {

                        UserAnnotation()

                        ForEach(displayedMeetings) { meeting in

                            if let coordinate = meeting.coordinate {

                                Marker(
                                    meeting.name,
                                    systemImage:
                                        meeting.isOnline
                                        ? "video.fill"
                                        : "person.3.fill",
                                    coordinate: coordinate
                                )
                            }
                        }
                    }
                    .frame(height: 230)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                    Text(
                        "Meetings within your search area, closest first."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }

                // MARK: - Meeting List

                VStack(alignment: .leading, spacing: 16) {

                    Text("Meetings Near You")
                        .font(.title2)
                        .fontWeight(.semibold)

                    if isLoadingMeetings {

                        HStack(spacing: 12) {

                            ProgressView()

                            Text(
                                "Finding meetings near you..."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .padding()
                    }

                    else if let meetingsErrorMessage {

                        VStack(alignment: .leading, spacing: 12) {

                            Label(
                                "Couldn't Load Meetings",
                                systemImage:
                                    "exclamationmark.triangle.fill"
                            )
                            .font(.headline)
                            .foregroundStyle(.orange)

                            Text(meetingsErrorMessage)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Button(
                                "Try Again"
                            ) {
                                locationService.requestLocation()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(
                            Color(.secondarySystemBackground)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }

                    else if nearbyMeetings.isEmpty {

                        VStack(alignment: .leading, spacing: 12) {

                            Label(
                                "Waiting for Your Location",
                                systemImage:
                                    "location.circle.fill"
                            )
                            .font(.headline)

                            Text(
                                locationService.errorMessage
                                    ?? "HopeLine uses your location to find recovery meetings near you — wherever you are."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                            Button(
                                "Find Meetings Near Me"
                            ) {
                                locationService.requestLocation()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding()
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .background(
                            Color(.secondarySystemBackground)
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                    }

                    else {

                        Text(
                            "\(filteredMeetings.count) meetings found"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)

                        ForEach(filteredMeetings) { meeting in

                            MeetingCard(
                                meeting: meeting
                            ) { selected in

                                openDirections(
                                    to: selected
                                )
                            }
                        }
                    }
                }

                // MARK: - Can't Find a Meeting

                VStack(alignment: .leading, spacing: 12) {

                    Label(
                        "Can't find what you need?",
                        systemImage:
                            "questionmark.circle.fill"
                    )
                    .font(.headline)

                    Text(
                        "HopeLine lists Narcotics Anonymous meetings across the United States. More meeting sources and recovery resources will be added as HopeLine grows."
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(.secondarySystemBackground)
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
            }
            .padding()
        }
        .navigationTitle("Meetings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            locationService.requestLocation()
        }
        .onChange(of: locationService.currentLocation) { _, location in

            guard let location else {
                return
            }

            mapPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.10,
                        longitudeDelta: 0.10
                    )
                )
            )

            Task {
                await loadMeetings(near: location)
            }
        }
    }

    // MARK: - Load Meetings

    private func loadMeetings(near location: CLLocation) async {

        isLoadingMeetings = true
        meetingsErrorMessage = nil

        do {

            nearbyMeetings =
                try await NearbyMeetingService.shared
                .fetchNearbyMeetingsWithWidening(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
        }

        catch {

            meetingsErrorMessage =
                "HopeLine couldn't load meetings right now. Check your internet connection and try again."
        }

        isLoadingMeetings = false
    }

    // MARK: - Directions

    private func openDirections(to meeting: NearbyMeeting) {

        guard let coordinate = meeting.coordinate
        else {
            return
        }

        let urlString =
            "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)&q=\(meeting.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        guard let url = URL(string: urlString)
        else {
            return
        }

        openURL(url)
    }

    // MARK: - Displayed Meetings

    // Everything within the map area — used for map pins

    private var displayedMeetings: [NearbyMeeting] {
        nearbyMeetings
    }

    // MARK: - Filtered Meetings

    private var filteredMeetings: [NearbyMeeting] {

        nearbyMeetings.filter { meeting in

            let matchesType: Bool

            switch selectedFilter {

            case .all:
                matchesType = true

            case .inPerson:
                matchesType =
                    meeting.isOnline == false

            case .online:
                matchesType =
                    meeting.isOnline
            }

            let trimmedSearch =
                searchText.trimmingCharacters(
                    in: .whitespacesAndNewlines
                )

            let matchesSearch =
                trimmedSearch.isEmpty ||
                meeting.name.localizedCaseInsensitiveContains(
                    trimmedSearch
                ) ||
                (meeting.city ?? "")
                    .localizedCaseInsensitiveContains(trimmedSearch) ||
                (meeting.address ?? "")
                    .localizedCaseInsensitiveContains(trimmedSearch)

            return matchesType && matchesSearch
        }
    }
}

// MARK: - Meeting Card

private struct MeetingCard: View {

    let meeting: NearbyMeeting

    let onDirections: (NearbyMeeting) -> Void

    private var meetingType: MeetingType {

        meeting.isOnline ? .online : .inPerson
    }

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            // MARK: Header

            HStack(alignment: .top) {

                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {

                    Text(meeting.name)
                        .font(.headline)

                    MeetingTypeBadge(
                        type: meetingType
                    )
                }

                Spacer()

                if let distance =
                    meeting.formattedDistance {

                    Text(distance)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }

            Divider()

            // MARK: Date and Time

            Label(
                "\(meeting.meetingDay ?? "Call for details") at \(meeting.formattedTime ?? "Call for details")",
                systemImage: "calendar"
            )
            .font(.subheadline)

            // MARK: Location

            Label(
                meeting.isOnline
                    ? "Online Meeting"
                    : meeting.locationDescription,
                systemImage:
                    meeting.isOnline
                    ? "video.fill"
                    : "mappin.and.ellipse"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)

            // MARK: Actions

            HStack {

                if meeting.isOnline {

                    if
                        let urlString =
                            meeting.onlineURL,
                        let url = URL(string: urlString) {

                        Link(
                            destination: url
                        ) {

                            Label(
                                "Join",
                                systemImage: "video.fill"
                            )
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                else {

                    Button {

                        onDirections(meeting)

                    } label: {

                        Label(
                            "Directions",
                            systemImage:
                                "arrow.triangle.turn.up.right.diamond.fill"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .background(
            Color(.secondarySystemBackground)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

// MARK: - Meeting Type Badge

private struct MeetingTypeBadge: View {

    let type: MeetingType

    var body: some View {

        Label(
            type.title,
            systemImage: type.icon
        )
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(type.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            type.color.opacity(0.12)
        )
        .clipShape(
            Capsule()
        )
    }
}

// MARK: - Meeting Type

private enum MeetingType {

    case inPerson
    case online

    var title: String {

        switch self {

        case .inPerson:
            return "In Person"

        case .online:
            return "Online"
        }
    }

    var icon: String {

        switch self {

        case .inPerson:
            return "person.3.fill"

        case .online:
            return "video.fill"
        }
    }

    var color: Color {

        switch self {

        case .inPerson:
            return .blue

        case .online:
            return .green
        }
    }
}

// MARK: - Meeting Filter

private enum MeetingFilter:
    String,
    CaseIterable,
    Identifiable {

    case all
    case inPerson
    case online

    var id: String {
        rawValue
    }

    var title: String {

        switch self {

        case .all:
            return "All"

        case .inPerson:
            return "In Person"

        case .online:
            return "Online"
        }
    }
}

// MARK: - Nearby Meeting Display Helpers

private extension NearbyMeeting {

    var locationDescription: String {

        let parts =
            [
                address,
                city,
                state
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        return
            parts.isEmpty
            ? "Call for details"
            : parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#Preview {

    NavigationStack {
        MeetingsView()
    }
}
