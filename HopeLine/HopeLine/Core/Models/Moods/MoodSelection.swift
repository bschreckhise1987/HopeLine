//
//  MoodSelection.swift
//  HopeLine
//
//  Created by StalkyTwig1987 on 11/1/26.
//


import Foundation

struct MoodSelection: Codable, Identifiable {
    let id: UUID
    let checkInId: UUID
    let moodName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case checkInId = "checkin_id"
        case moodName = "mood_name"
    }
}
