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

    // The user's appearance choice (System/Light/Dark), saved to the device
    // with @AppStorage so it persists across app launches.
    @AppStorage("appearancePreference")
    private var appearancePreference =
        AppearanceOption.system.rawValue


    // MARK: - Accessibility

    // The three in-app accessibility preferences. Each one is read here at the
    // root so it can be applied to the entire view hierarchy at once.
    @AppStorage("enhancedReadability")
    private var enhancedReadability = false

    @AppStorage("reduceVisualEffects")
    private var reduceVisualEffects = false

    @AppStorage("alwaysShowLabels")
    private var alwaysShowLabels = false


    // MARK: - Preferred Color Scheme

    // Converts the saved appearance choice into a ColorScheme for
    // .preferredColorScheme(). Nil (System) means follow the device setting.
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

// Applies all three in-app accessibility preferences to the whole app at
// once: larger text, reduced animations, and always-visible labels.
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

// When Enhanced Readability is on, bumps the app's text up to a larger
// Dynamic Type size so every supported label gets bigger.
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

// When Always Show Text Labels is on, switches every Label in the app to
// show both its title and icon instead of icon-only.
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
