//
// SupabaseManager.swift
//
// HopeLine
// Created by StalkTwig1987 on 10/31/26
//

import Foundation
import Supabase

final class SupabaseManager {

    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: AppConfig.supabaseURL,
            supabaseKey: AppConfig.supabaseAnonKey
        )
    }
}
