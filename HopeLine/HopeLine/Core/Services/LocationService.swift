//
//  LocationService.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/4/26.
//

import Foundation
import CoreLocation
import Combine


// MARK: - Location Service

// Wraps CoreLocation so the rest of the app can read the user's location
// without touching CLLocationManager directly. Views observe the
// published properties; the delegate callbacks keep them updated.
@MainActor
final class LocationService: NSObject, ObservableObject {

    // MARK: - Published Properties

    // The user's most recent location, published so views react when it arrives.
    @Published private(set) var currentLocation: CLLocation?

    // The current location permission status, kept in sync by the delegate.
    @Published private(set) var authorizationStatus:
        CLAuthorizationStatus = .notDetermined

    // True while a location request is in flight.
    @Published private(set) var isLoading = false

    // A user-friendly message explaining any location problem.
    @Published var errorMessage: String?


    // MARK: - Location Manager

    // The system location manager. Kilometer accuracy is plenty for
    // finding nearby meetings and saves battery.
    private let locationManager =
        CLLocationManager()


    // MARK: - Initialization

    override init() {

        super.init()

        locationManager.delegate = self

        locationManager.desiredAccuracy =
            kCLLocationAccuracyKilometer

        authorizationStatus =
            locationManager.authorizationStatus
    }


    // MARK: - Request Location

    // The main entry point. Checks that location services are on, then
    // asks for permission, fetches the location, or explains why it
    // can't — with a plain-language message for every permission state.
    func requestLocation() {

        errorMessage = nil

        guard CLLocationManager
            .locationServicesEnabled()
        else {

            errorMessage =
                "Location services are turned off on this device."

            return
        }


        switch locationManager
            .authorizationStatus {

        case .notDetermined:

            locationManager
                .requestWhenInUseAuthorization()


        case .authorizedWhenInUse,
             .authorizedAlways:

            loadCurrentLocation()


        case .denied:

            errorMessage =
                """
                Location access is turned off for HopeLine. Enable location access in Settings to find meetings near you.
                """


        case .restricted:

            errorMessage =
                """
                Location access is restricted on this device.
                """


        @unknown default:

            errorMessage =
                """
                HopeLine couldn't determine the current location permission status.
                """
        }
    }


    // MARK: - Load Current Location

    // Fetches the current location once permission is already granted.
    // If permission hasn't been decided yet, falls back to requesting it.
    func loadCurrentLocation() {

        guard CLLocationManager
            .locationServicesEnabled()
        else {

            errorMessage =
                "Location services are unavailable."

            return
        }


        guard
            authorizationStatus ==
                .authorizedWhenInUse
                ||
            authorizationStatus ==
                .authorizedAlways
        else {

            requestLocation()

            return
        }


        isLoading = true
        errorMessage = nil

        locationManager.requestLocation()
    }


    // MARK: - Coordinates

    // Convenience accessors so views can grab just what they need
    // (for the nearby_meetings database function) without unwrapping
    // the full CLLocation themselves.
    var latitude: Double? {

        currentLocation?
            .coordinate
            .latitude
    }


    var longitude: Double? {

        currentLocation?
            .coordinate
            .longitude
    }


    var coordinate:
        CLLocationCoordinate2D? {

        currentLocation?.coordinate
    }
}


// MARK: - CLLocationManagerDelegate

// CLLocationManager calls these on a background thread, so each one hops
// to the main actor before touching published state.
extension LocationService:
    CLLocationManagerDelegate {

    // Called whenever the permission status changes — including the
    // moment the user answers the permission prompt.
    nonisolated func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        let status =
            manager.authorizationStatus

        Task { @MainActor in

            authorizationStatus = status


            switch status {

            case .authorizedWhenInUse,
                 .authorizedAlways:

                loadCurrentLocation()


            case .denied:

                isLoading = false

                errorMessage =
                    """
                    Location access was denied. HopeLine needs your location to find meetings near you.
                    """


            case .restricted:

                isLoading = false

                errorMessage =
                    """
                    Location access is restricted on this device.
                    """


            case .notDetermined:

                break


            @unknown default:

                isLoading = false

                errorMessage =
                    """
                    HopeLine couldn't determine the location permission status.
                    """
            }
        }
    }


    // Called when the device reports a location. Keeps only the newest
    // fix and clears any previous error.
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let newestLocation =
                locations.last
        else {
            return
        }


        Task { @MainActor in

            currentLocation =
                newestLocation

            isLoading = false

            errorMessage = nil
        }
    }


    // Called when the location request fails. Stops the loading state
    // and surfaces the error to the user.
    nonisolated func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        Task { @MainActor in

            isLoading = false

            errorMessage =
                """
                HopeLine couldn't determine your current location. \(error.localizedDescription)
                """
        }
    }
}
