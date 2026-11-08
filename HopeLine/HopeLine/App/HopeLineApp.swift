//
//  HopeLineApp.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI


@main
struct HopeLineApp: App {

    // MARK: - Authentication

    @StateObject private var authManager =
        AuthManager()


    // MARK: - Appearance

    @AppStorage("appearancePreference")
    private var appearancePreference =
        AppearanceOption.system.rawValue


    private var preferredColorScheme:
        ColorScheme? {

        AppearanceOption(
            rawValue: appearancePreference
        )?.colorScheme
    }


    // MARK: - App

    var body: some Scene {

        WindowGroup {

            AuthenticationRootView()
                .environmentObject(
                    authManager
                )
                .preferredColorScheme(
                    preferredColorScheme
                )
        }
    }
}
