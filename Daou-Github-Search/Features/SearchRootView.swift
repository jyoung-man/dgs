//
//  SearchRootView.swift
//  Daou-Github-Search
//
//  Created by daou-mrlhs on 8/25/25.
//

import SwiftUI

struct SearchRootView: View {
    @StateObject var viewModel = SearchViewModel()
    
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

            List(viewModel.repositories) { repo in
                SearchRow(repository: repo)
                    .task {
                        if repo == viewModel.repositories.last {
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
