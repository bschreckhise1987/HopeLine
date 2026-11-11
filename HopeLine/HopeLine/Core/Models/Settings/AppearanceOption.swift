//
//  AppearanceOption.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/8/26.
//

import SwiftUI

// The user's saved appearance choice. Stored as a raw String so it can be
// persisted directly with @AppStorage. CaseIterable powers the segmented
// control; Identifiable lets SwiftUI loop over the options.
enum AppearanceOption: String, CaseIterable, Identifiable{
    
    // Follows whatever light/dark mode the iPhone is currently set to.
    case system
    case light
    case dark
    
    // Unique identifier used by SwiftUI's ForEach and Picker tags.
    var id: String {
        rawValue
    }
    
    // The display name shown to the user in the Appearance segmented control.
    var title: String {
        
        switch self {
        
        case .system:
            return "System"
            
        case .light:
            return "Light"
            
        case .dark:
            return "Dark"
        }
    }
    
    // Maps the choice to SwiftUI's ColorScheme, applied at the app root with
    // .preferredColorScheme(). Returning nil for .system lets the app follow
    // the device's light/dark setting instead of forcing one.
    var colorScheme: ColorScheme? {
        switch self {
            
        case .system:
            return nil
            
        case .light:
            return .light
            
        case .dark:
            return .dark
        }
    }
}
