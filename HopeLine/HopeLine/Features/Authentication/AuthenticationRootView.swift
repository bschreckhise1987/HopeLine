//
//  AuthenticationRootView.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//

import SwiftUI

struct AuthenticationRootView: View {

    @EnvironmentObject var auth: AuthManager

    var body: some View {
        Group {
            if auth.isLoading {
                ProgressView("Loading HopeLine...")
            } else if auth.isAuthenticated {
                HomeView()
            } else {
                LoginView()
            }
        }
    }
}
