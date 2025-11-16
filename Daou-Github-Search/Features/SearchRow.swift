//
//  SearchRow.swift
//  Daou-Github-Search
//
//  Created by 박재영 on 11/16/25.
//

import SwiftUI

struct SearchRow: View {
    var repository: Repository
    @ObservedObject var viewModel: GitHubSearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text(repository.name)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .bold()
                Spacer()
                Button(action: {
                    viewModel.toggleStar(for: repository)
                }) {
                    Image(systemName: (repository.isStarred ?? false) ? "star.fill" : "star")
                        .foregroundStyle(.yellow)

                }
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
