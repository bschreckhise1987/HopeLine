//
// SupabaseManager.swift
//
// HopeLine
// Created by StalkTwig1987 on 10/31/26
//

import Foundation
import Supabase

// Single shared connection point to HopeLine's Supabase backend. Every
// service in the app goes through this one client so there's only ever
// one database connection configured with the URL and anon key.
final class SupabaseManager {

    // The one and only instance, accessed as SupabaseManager.shared.
    static let shared = SupabaseManager()

    // The configured client that services use for queries and auth.
    let client: SupabaseClient

    // private init enforces the singleton pattern — no one can create
    // a second manager.
    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }
}
