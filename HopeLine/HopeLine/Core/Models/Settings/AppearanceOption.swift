//
//  AppearanceOption.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/8/26.
//

import SwiftUI

enum AppearanceOption: String, CaseIterable, Identifiable{
    
    case system
    case light
    case dark
    
    var id: String {
        rawValue
    }
    
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
