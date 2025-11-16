//
//  SearchRootView.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import SwiftUI

struct SearchRootView: View {
    private let loginService: GitHubLoginService
    @StateObject private var viewModel: GitHubSearchViewModel

    init(loginService: GitHubLoginService) {
        self.loginService = loginService
        _viewModel = StateObject(
            wrappedValue: GitHubSearchViewModel(
                client: GitHubClient(session: .default),
                loginService: loginService
            )
        )
    }
    var body: some View {
        VStack() {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("검색어를 입력하세요", text: $viewModel.keyword)
                        .onSubmit {
                            viewModel.search(reset: true)
                        }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal)

            List(viewModel.totalRepositories) { repo in
                SearchRow(repository: repo, viewModel: viewModel)
                    .task {
                        if repo == viewModel.totalRepositories.last {
                            viewModel.loadNextPage()
                        }
                    }
            }
            .listStyle(PlainListStyle())
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
