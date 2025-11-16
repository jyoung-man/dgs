//
//  ProfileRootView.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import SwiftUI

struct ProfileRootView: View {
    private let loginService: GitHubLoginService

    @StateObject private var viewModel: GitHubSearchViewModel

    init(loginService: GitHubLoginService) {
        self.loginService = loginService
        _viewModel = StateObject(
            wrappedValue: GitHubSearchViewModel(
                loginService: loginService
            )
        )
    }

    var body: some View {
        VStack {
            List(viewModel.starredRepositories) { repo in
                SearchRow(repository: repo, viewModel: viewModel)
            }
            .listStyle(PlainListStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
