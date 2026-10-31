//
//  Environment.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 10/31/26.
//
import Foundation

enum Environment {

    static var supabaseURL: URL {
        guard
            let path = Bundle.main.path(
                forResource: "Config",
                ofType: "plist"
            ),
            let plist = NSDictionary(contentsOfFile: path),
            let urlString = plist["SUPABASE_URL"] as? String,
            let url = URL(string: urlString)
        else {
            fatalError("Missing SUPABASE_URL in Config.plist")
        }

        return url
    }

    static var supabaseAnonKey: String {
        guard
            let path = Bundle.main.path(
                forResource: "Config",
                ofType: "plist"
            ),
            let plist = NSDictionary(contentsOfFile: path),
            let key = plist["SUPABASE_ANON_KEY"] as? String
        else {
            fatalError("Missing SUPABASE_ANON_KEY in Config.plist")
        }

        return key
    }
}
