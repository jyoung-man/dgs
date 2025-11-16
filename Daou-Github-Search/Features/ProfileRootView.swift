//
//  ProfileRootView.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import SwiftUI

struct ProfileRootView: View {
    private let loginService: GitHubLoginService

    @StateObject private var viewModel: GitHubLoginViewModel

    init(loginService: GitHubLoginService) {
        self.loginService = loginService
        _viewModel = StateObject(
            wrappedValue: GitHubLoginViewModel(
                client: GitHubClient(session: .default),
                loginService: loginService
            )
        )
    }

    var body: some View {
        VStack {
            List(viewModel.repositories) { repo in
                SearchRow(repository: repo)
            }
            .listStyle(PlainListStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onReceive(loginService.loginCompletedPublisher) {
            viewModel.getStaredRepo()
        }
    }
}
