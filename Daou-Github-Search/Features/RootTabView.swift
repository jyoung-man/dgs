//
//  RootTabView.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import SwiftUI

struct RootTabView: View {
    private let loginService: GitHubLoginService
    @State private var showLogin = false
    @State private var isLoggedIn = false

    init(loginService: GitHubLoginService) {
        self.loginService = loginService
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                SearchRootView(loginService: loginService)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("GitHub").font(.headline)
                        }
                    }
            }
            .tabItem { Label("Search", systemImage: "magnifyingglass") }

            NavigationStack {
                ProfileRootView(loginService: loginService)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("GitHub").font(.headline)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(isLoggedIn ? "로그아웃" : "로그인") {
                                if isLoggedIn {
                                    // 로그아웃 처리 필요
                                    isLoggedIn = false
                                } else {
                                    showLogin = true
                                }
                            }
                        }
                    }
            }
            .tabItem { Label("Profile", systemImage: "person") }
        }
        .sheet(isPresented: $showLogin) {
            GitHubLoginSheet(loginService: loginService)
        }
        .onReceive(loginService.loginCompletedPublisher) {
            isLoggedIn = true
            showLogin = false
        }
    }
}

