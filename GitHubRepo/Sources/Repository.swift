//
//  Repository.swift
//  GitHubRepo
//
//  Created by RAFA on 7/17/24.
//

import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let description: String?
    let stargazersCount: Int
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}
