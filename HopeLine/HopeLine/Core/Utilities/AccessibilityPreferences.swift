//
//  AccessibilityPreferences.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/8/26.
//

import SwiftUI


// MARK: - Enhanced Readability

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
