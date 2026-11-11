//
//  AccessibilityPreferences.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/8/26.
//

import SwiftUI


// MARK: - Enhanced Readability

// Custom environment value so any view in the app can read whether the
// user turned on Enhanced Readability, without passing the preference
// down through every view initializer.
private struct HopeLineEnhancedReadabilityKey:
    EnvironmentKey {

    static let defaultValue = false
}


extension EnvironmentValues {

    var hopeLineEnhancedReadability: Bool {

        get {
            self[
                HopeLineEnhancedReadabilityKey.self
            ]
        }

        set {
            self[
                HopeLineEnhancedReadabilityKey.self
            ] = newValue
        }
    }
}


// MARK: - Reduce Visual Effects

// Environment value that views can read to skip or soften their animations
// when the user prefers fewer visual effects.
private struct HopeLineReduceVisualEffectsKey:
    EnvironmentKey {

    static let defaultValue = false
}


extension EnvironmentValues {

    var hopeLineReduceVisualEffects: Bool {

        get {
            self[
                HopeLineReduceVisualEffectsKey.self
            ]
        }

        set {
            self[
                HopeLineReduceVisualEffectsKey.self
            ] = newValue
        }
    }
}


// MARK: - Always Show Labels

// Environment value that views can read to show text alongside icons
// when the user wants labels visible.
private struct HopeLineAlwaysShowLabelsKey:
    EnvironmentKey {

    static let defaultValue = false
}


extension EnvironmentValues {

    var hopeLineAlwaysShowLabels: Bool {

        get {
            self[
                HopeLineAlwaysShowLabelsKey.self
            ]
        }

        set {
            self[
                HopeLineAlwaysShowLabelsKey.self
            ] = newValue
        }
    }
}
