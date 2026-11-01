//
//  MoodCheckIn.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//

//
//  MoodCheckIn.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//

import Foundation

struct MoodCheckIn: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let category: String
    let notes: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case category
        case notes
        case createdAt = "created_at"
    }
}
