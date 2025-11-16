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
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text(repository.name)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .bold()
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .padding(.leading, 12)
            .padding(.trailing, 12)

            HStack {
                if let description = repository.description {
                    Text(description)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 12) // 좌측 여백
                }
            }
            HStack {
                if let language = repository.language {
                    Text(language)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if let license = repository.license?.name {
                    Text("· \(license)")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                if let starCount = repository.starCount {
                    Text("· \(String(describing: starCount))")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .padding(.leading, 12) // 좌측 여백
        }
    }
}

#Preview {
    let repo = Repository(id: 123213213213, name: "test", fullName: "TEST repository", description: "test repository description", starCount: 500, language: "Swift", owner: Owner(name: "jyoung-man", avatarUrl: nil), license: License(key: "123213", name: "MIT", spdxId: "123124124"), isStarred: true)
    return Group {
        SearchRow(repository: repo)
    }
}
