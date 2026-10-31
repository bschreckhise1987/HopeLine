//
//  HopeLineApp.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

@main
struct HopeLineApp: App {

    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            AuthenticationRootView()
                .environmentObject(authManager)
        }
    }
}
