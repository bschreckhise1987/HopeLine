//
//  AuthManager.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//
import Foundation
import Combine
import Supabase

// The central authentication state for the whole app. Views observe this
// through .environmentObject so every screen knows whether the user is
// signed in, signed out, or still being checked.
@MainActor
final class AuthManager: ObservableObject {

    // Whether a user is currently signed in.
    @Published var isAuthenticated = false

    // True while the saved session is being restored on launch, so the app
    // can show a loading state instead of flashing the login screen.
    @Published var isLoading = true

    // The most recent authentication error, shown by the login UI.
    @Published var errorMessage: String?

    // The shared Supabase client that handles all auth requests.
    private let supabase = SupabaseManager.shared.client

    init() {
        // Start listening for auth changes right away so the app reacts
        // instantly when a session is restored, created, or ended.
        Task {
            await listenForAuthChanges()
        }
    }

    // MARK: - Listen for Authentication Changes

    // Reacts to every auth state change from Supabase (sign in, sign out,
    // session restore, token refresh) and updates the published state the
    // rest of the app observes.
    private func listenForAuthChanges() async {
        for await (_, session) in await supabase.auth.authStateChanges {
            isAuthenticated = session != nil
            isLoading = false
        }
    }

    // MARK: - Sign Up

    // Creates a new account with Supabase. On failure, saves the error
    // message for the UI and rethrows so the caller knows it failed.
    func signUp(
        email: String,
        password: String
    ) async throws {

        errorMessage = nil

        do {
            try await supabase.auth.signUp(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign In

    // Signs in an existing user. On failure, saves the error message for
    // the UI and rethrows so the caller knows it failed.
    func signIn(
        email: String,
        password: String
    ) async throws {

        errorMessage = nil

        do {
            try await supabase.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
    }

    // MARK: - Sign Out

    // Signs the user out. Unlike sign in/up, errors are only shown, not
    // rethrown, since there's nothing for a caller to recover from.
    func signOut() async {

        errorMessage = nil

        do {
            try await supabase.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

