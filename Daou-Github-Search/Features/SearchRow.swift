//
//  SearchRow.swift
//  Daou-Github-Search
//
//  Created by 박재영 on 11/16/25.
//

import SwiftUI

struct SearchRow: View {
    var repository: Repository
    
    var body: some View {
        HStack {
            Text(repository.name)
            Spacer()
            
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
            
        }
    }
}

#Preview {
    let repo = Repository(id: 123213213213, name: "test", fullName: "TEST repository", description: "test repository", starCount: 500, language: "Swift", owner: Owner(name: "jyoung-man", avatarUrl: nil), license: nil, isStarred: true)
    return Group {
        SearchRow(repository: repo)
    }
}
