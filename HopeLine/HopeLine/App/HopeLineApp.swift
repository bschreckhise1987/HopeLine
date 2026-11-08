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


    // MARK: - Accessibility

    @AppStorage("enhancedReadability")
    private var enhancedReadability = false

    @AppStorage("reduceVisualEffects")
    private var reduceVisualEffects = false

    @AppStorage("alwaysShowLabels")
    private var alwaysShowLabels = false


    // MARK: - Preferred Color Scheme

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
                .modifier(
                    HopeLineAccessibilityModifier(
                        enhancedReadability:
                            enhancedReadability,
                        reduceVisualEffects:
                            reduceVisualEffects,
                        alwaysShowLabels:
                            alwaysShowLabels
                    )
                )
        }
    }
}


// MARK: - HopeLine Accessibility Modifier

private struct HopeLineAccessibilityModifier:
    ViewModifier {

    let enhancedReadability: Bool

    let reduceVisualEffects: Bool

    let alwaysShowLabels: Bool


    func body(
        content: Content
    ) -> some View {

        content
            .modifier(
                EnhancedReadabilityModifier(
                    isEnabled:
                        enhancedReadability
                )
            )
            .modifier(
                HopeLineLabelStyleModifier(
                    alwaysShowLabels:
                        alwaysShowLabels
                )
            )
            .transaction { transaction in

                if reduceVisualEffects {

                    transaction.animation = nil

                    transaction.disablesAnimations =
                        true
                }
            }
            .environment(
                \.hopeLineReduceVisualEffects,
                reduceVisualEffects
            )
            .environment(
                \.hopeLineAlwaysShowLabels,
                alwaysShowLabels
            )
            .environment(
                \.hopeLineEnhancedReadability,
                enhancedReadability
            )
    }
}


// MARK: - Enhanced Readability Modifier

private struct EnhancedReadabilityModifier:
    ViewModifier {

    let isEnabled: Bool


    @ViewBuilder
    func body(
        content: Content
    ) -> some View {

        if isEnabled {

            content
                .dynamicTypeSize(
                    .accessibility1
                )

        } else {

            content
        }
    }
}


// MARK: - Label Style Modifier

private struct HopeLineLabelStyleModifier:
    ViewModifier {

    let alwaysShowLabels: Bool


    @ViewBuilder
    func body(
        content: Content
    ) -> some View {

        if alwaysShowLabels {

            content
                .labelStyle(
                    .titleAndIcon
                )

        } else {

            content
                .labelStyle(
                    .automatic
                )
        }
    }
}
