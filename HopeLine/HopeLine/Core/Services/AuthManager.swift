//
//  AuthManager.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//
import Foundation
import Combine
import Supabase

@MainActor
final class AuthManager: ObservableObject {

    @Published var isAuthenticated = false
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let supabase = SupabaseManager.shared.client

    init() {
        Task {
            await listenForAuthChanges()
        }
    }

    // MARK: - Listen for Authentication Changes

    private func listenForAuthChanges() async {
        for await (_, session) in await supabase.auth.authStateChanges {
            isAuthenticated = session != nil
            isLoading = false
        }
    }

    // MARK: - Sign Up

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

    func signOut() async {

        errorMessage = nil

        do {
            try await supabase.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

