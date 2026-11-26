//
//  MeetingDetailView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/20/26.
//

import SwiftUI
import MapKit
import Supabase

// The full detail screen for one meeting. Shows every piece of
// data the database holds for the meeting, plus a map pin and
// a Get Directions action.
struct MeetingDetailView: View {

    let meeting: NearbyMeeting

    @Environment(\.openURL) private var openURL

    // MARK: - Favorite State

    // Whether this meeting is in the user's favorites.
    @State private var isFavorite = false

    // Prevents double taps while a favorite change
    // is still in flight.
    @State private var isTogglingFavorite = false

    // Shown when favoriting or unfavoriting fails.
    @State private var showFavoriteError = false
    @State private var favoriteErrorMessage: String?

    // Uses the shared service instance —
    // MeetingFavoriteService has a private
    // initializer (singleton pattern).
    private let favoriteService = MeetingFavoriteService.shared

    // MARK: - Display Helpers

    // Whether this meeting happens in person or online.
    private var meetingType: MeetingType {
        meeting.isOnline ? .online : .inPerson
    }

    // The full street address from the parts the database
    // has on file, or nil when there is nothing to show.
    private var fullAddress: String? {

        let parts =
            [
                meeting.address,
                meeting.city,
                meeting.state,
                meeting.postalCode
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        return
            parts.isEmpty
            ? nil
            : parts.joined(separator: ", ")
    }

    // The end time formatted for display, using the same
    // style as the meeting's start time.
    private var formattedEndTime: String? {

        guard
            let endTime = meeting.endTime,
            !endTime.isEmpty
        else {
            return nil
        }

        let components =
            endTime.split(separator: ":")

        guard
            components.count >= 2,
            let hour = Int(components[0]),
            let minute = Int(components[1])
        else {
            return endTime
        }

        let isPM = hour >= 12
        let displayHour = hour % 12 == 0 ? 12 : hour % 12

        return
            "\(displayHour):\(String(format: "%02d", minute)) \(isPM ? "PM" : "AM")"
    }

    // The schedule line: the day plus the time range when
    // the database has them.
    private var scheduleDescription: String {

        var parts: [String] = []

        if
            let day = meeting.meetingDay,
            !day.isEmpty {

            parts.append(day)
        }

        if let start = meeting.formattedTime {

            var time = start

            if let end = formattedEndTime {

                time += " – \(end)"
            }

            parts.append(time)
        }

        guard !parts.isEmpty else {
            return "Call for details"
        }

        return parts.joined(separator: " at ")
    }

    // MARK: - Body

    var body: some View {

        ScrollView {

            VStack(alignment: .leading, spacing: 20) {

                // MARK: Header

                VStack(alignment: .leading, spacing: 8) {

                    Text(meeting.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 8) {

                        MeetingTypeBadge(
                            type: meetingType
                        )

                        if
                            let distance =
                                meeting.formattedDistance {

                            Text(distance)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }

                        Spacer()

                        // Taps the heart to favorite this
                        // meeting or remove it. Filled when
                        // favorited, outline when not.
                        if meeting.meetingGuideId != nil {

                            Button {
                                Task {
                                    await toggleFavorite()
                                }
                            } label: {

                                Image(
                                    systemName:
                                        isFavorite
                                        ? "heart.fill"
                                        : "heart"
                                )
                                .font(.title3)
                                .foregroundStyle(
                                    isFavorite
                                        ? .red
                                        : .secondary
                                )
                            }
                            .buttonStyle(
                                .plain
                            )
                            .disabled(
                                isTogglingFavorite
                            )
                        }
                    }
                }

                // MARK: Map

                if
                    let coordinate =
                        meeting.coordinate {

                    Map(
                        initialPosition: .region(
                            MKCoordinateRegion(
                                center: coordinate,
                                span: MKCoordinateSpan(
                                    latitudeDelta: 0.01,
                                    longitudeDelta: 0.01
                                )
                            )
                        )
                    ) {
                        Marker(
                            meeting.name,
                            coordinate: coordinate
                        )
                    }
                    .frame(height: 220)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: 16
                        )
                    )
                    .allowsHitTesting(false)
                }

                // MARK: Details Card

                VStack(alignment: .leading, spacing: 14) {

                    // The meeting type from the
                    // database (NA, AA, and so on).
                    if
                        let type = meeting.meetingType,
                        !type.isEmpty {

                        Label(
                            type,
                            systemImage:
                                "person.2.fill"
                        )
                        .font(.subheadline)
                    }

                    // Schedule

                    Label(
                        scheduleDescription,
                        systemImage:
                            "calendar"
                    )
                    .font(.subheadline)

                    // Location

                    if meeting.isOnline {

                        Label(
                            "Online Meeting",
                            systemImage:
                                "video.fill"
                        )
                        .font(.subheadline)
                    }
                    else {

                        Label(
                            fullAddress
                                ?? "Call for details",
                            systemImage:
                                "mappin.and.ellipse"
                        )
                        .font(.subheadline)
                    }
                }
                .padding()
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .background(
                    Color(
                        .secondarySystemBackground
                    )
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )

                // MARK: Online Link

                if
                    meeting.isOnline,
                    let urlString = meeting.onlineURL,
                    let url = URL(string: urlString) {

                    Link(
                        "Join Online Meeting",
                        destination: url
                    )
                    .frame(
                        maxWidth: .infinity
                    )
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                }

                // MARK: Directions

                if !meeting.isOnline {

                    Button {

                        openDirections()

                    } label: {

                        Label(
                            "Get Directions",
                            systemImage:
                                "map.fill"
                        )
                        .frame(
                            maxWidth: .infinity
                        )
                    }
                    .buttonStyle(
                        .borderedProminent
                    )
                    .controlSize(.large)
                }
            }
            .padding()
        }
        .navigationTitle(
            "Meeting Details"
        )
        .navigationBarTitleDisplayMode(
            .inline
        )
        .task {
            await loadFavoriteState()
        }
        .alert(
            "Couldn't Save Favorite",
            isPresented: $showFavoriteError
        ) {

            Button(
                "OK",
                role: .cancel
            ) { }
        } message: {

            Text(
                favoriteErrorMessage ??
                    "Something went wrong. Please try again."
            )
        }
    }

    // MARK: - Load Favorite State

    // Best effort: if the read fails, the heart simply
    // starts unfilled.
    private func loadFavoriteState() async {

        guard
            let favorites =
                try? await favoriteService
                    .fetchFavoriteGuideIds()
        else {
            return
        }

        isFavorite =
            favorites.contains(
                meeting.meetingGuideId ?? ""
            )
    }

    // MARK: - Toggle Favorite

    // Favorites this meeting if it isn't favorited yet,
    // or removes it if it already is.
    private func toggleFavorite() async {

        guard
            let guideId =
                meeting.meetingGuideId,
            !isTogglingFavorite
        else {
            return
        }

        isTogglingFavorite = true

        do {

            if isFavorite {

                try await favoriteService
                    .unfavoriteMeeting(
                        guideId: guideId
                    )

                isFavorite = false
            }

            else {

                try await favoriteService
                    .favoriteMeeting(
                        guideId: guideId
                    )

                isFavorite = true
            }
        }

        catch {

            // Favoriting requires a signed-in account;
            // other failures show a generic message.
            if error is AuthError {
                favoriteErrorMessage =
                    "Sign in to save favorite meetings to your account."
            } else {
                favoriteErrorMessage =
                    "HopeLine couldn't save this favorite. Check your internet connection and try again."
            }

            showFavoriteError = true
        }

        isTogglingFavorite = false
    }

    // MARK: - Directions

    // Opens Apple Maps with this meeting as the destination.
    private func openDirections() {

        guard
            let coordinate =
                meeting.coordinate
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
}
