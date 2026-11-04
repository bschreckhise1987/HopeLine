//
//  MeetingsView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import SwiftUI
import MapKit

struct MeetingsView: View {

    @StateObject private var locationService = LocationService()
    @State private var searchText = ""
    @State private var selectedFilter: MeetingFilter = .all

    @State private var mapPosition: MapCameraPosition = .userLocation(followsHeading: false, fallback: .automatic)

    private let sampleMeetings: [MeetingPreview] = [
        MeetingPreview(
            name: "New Beginnings",
            day: "Monday",
            time: "7:00 PM",
            location: "Community Center",
            type: .inPerson
        ),

        MeetingPreview(
            name: "One Day at a Time",
            day: "Wednesday",
            time: "6:30 PM",
            location: "Online Meeting",
            type: .online
        ),

        MeetingPreview(
            name: "Hope in Recovery",
            day: "Friday",
            time: "8:00 PM",
            location: "Recovery Center",
            type: .inPerson
        )
    ]


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
                    }
                    .frame(height: 230)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                    Text(
                        "Meeting locations will appear on the map when live meeting data is connected."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }


                // MARK: - Meeting List

                VStack(alignment: .leading, spacing: 16) {

                    Text("Upcoming Meetings")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text(
                        "Sample meetings are shown while the meeting service is being developed."
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    ForEach(filteredMeetings) { meeting in

                        MeetingCard(
                            meeting: meeting
                        )
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
                        "More meeting sources and recovery resources will be added as HopeLine's meeting tools are developed."
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
        }
    }


    // MARK: - Filtered Meetings

    private var filteredMeetings: [MeetingPreview] {

        sampleMeetings.filter { meeting in

            let matchesType: Bool

            switch selectedFilter {

            case .all:
                matchesType = true

            case .inPerson:
                matchesType =
                    meeting.type == .inPerson

            case .online:
                matchesType =
                    meeting.type == .online
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
                meeting.location.localizedCaseInsensitiveContains(
                    trimmedSearch
                )

            return matchesType && matchesSearch
        }
    }
}


// MARK: - Meeting Card

private struct MeetingCard: View {

    let meeting: MeetingPreview

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
                        type: meeting.type
                    )
                }

                Spacer()

                Image(
                    systemName:
                        meeting.type.icon
                )
                .font(.title2)
                .foregroundStyle(
                    meeting.type.color
                )
            }


            Divider()


            // MARK: Date and Time

            Label(
                "\(meeting.day) at \(meeting.time)",
                systemImage: "calendar"
            )
            .font(.subheadline)


            // MARK: Location

            Label(
                meeting.location,
                systemImage:
                    meeting.type == .online
                    ? "video.fill"
                    : "mappin.and.ellipse"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)


            // MARK: Actions

            HStack {

                Button {
                    // Meeting details come later.
                } label: {

                    Label(
                        "Details",
                        systemImage:
                            "info.circle"
                    )
                }
                .buttonStyle(.bordered)


                Spacer()


                if meeting.type == .inPerson {

                    Button {
                        // Map directions come later.
                    } label: {

                        Label(
                            "Directions",
                            systemImage:
                                "arrow.triangle.turn.up.right.diamond.fill"
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )

                } else {

                    Button {
                        // Online meeting joining comes later.
                    } label: {

                        Label(
                            "Join",
                            systemImage:
                                "video.fill"
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
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


// MARK: - Meeting Preview

private struct MeetingPreview: Identifiable {

    let id = UUID()

    let name: String
    let day: String
    let time: String
    let location: String
    let type: MeetingType
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


// MARK: - Preview

#Preview {

    NavigationStack {
        MeetingsView()
    }
}
