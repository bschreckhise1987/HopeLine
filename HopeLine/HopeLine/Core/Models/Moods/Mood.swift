//
//  Mood.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//

import Foundation

struct Mood: Codable, Identifiable, Hashable {
    let id: UUID
    let category: String
    let emoji: String
    let name: String
}
