//
//  Repository.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import Foundation

struct RepositoryResponse: Codable {
    let total_count: Int
    let incomplete_results: Bool
    let items: [Repository]
}

class Repository: Identifiable, ObservableObject, Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String?
    let description: String?
    let starCount: Int?
    let language: String?
    let owner: Owner
    let license: License?

    @Published var isStarred: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, description, owner, language, license
        case fullName = "full_name"
        case starCount = "stargazers_count"
    }

    init(id: Int, name: String, fullName: String?, description: String?, starCount: Int?, language: String?, owner: Owner, license: License?, isStarred: Bool?) {
        self.id = id
        self.name = name
        self.fullName = fullName
        self.description = description
        self.starCount = starCount
        self.language = language
        self.owner = owner
        self.license = license
        self.isStarred = isStarred
    }
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.id == rhs.id
    }
}
