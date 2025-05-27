//
//  Tokens.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation

struct Tokens: Codable {
    let tokenType: String
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    private let expiresIn: Double
    
    private enum CodingKeys: CodingKey {
        case tokenType
        case accessToken
        case refreshToken
        case expiresIn
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tokenType = try container.decode(String.self, forKey: .tokenType)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decode(String.self, forKey: .refreshToken)
        self.expiresIn = try container.decode(Double.self, forKey: .expiresIn)
        self.expiresAt = Date.now.addingTimeInterval(expiresIn)
    }
}
