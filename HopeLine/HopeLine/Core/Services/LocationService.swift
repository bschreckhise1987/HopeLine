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

@MainActor
final class LocationService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var currentLocation: CLLocation?

    @Published private(set) var authorizationStatus:
        CLAuthorizationStatus = .notDetermined

    @Published private(set) var isLoading = false

    @Published var errorMessage: String?


    // MARK: - Location Manager

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

extension LocationService:
    CLLocationManagerDelegate {

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
