//
//  User.swift
//  ShortVideoFeed
//
//  Created by Tes on 02/02/2026.
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let url: String
    
    var username: String {
        // Extract username from name or generate from ID
        return "@" + name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    var profileURL: URL? {
        URL(string: url)
    }
}
