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
                            viewModel.search(reset: false)
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
                
                /*
                 .task {
                     if repo == viewModel.repositories.last {
                         await viewModel.loadNextPage()
                     }
                 }
                 
                 
                 ScrollView {
                     LazyVStack {
                         ForEach(viewModel.repositories) { repo in
                             RepoRow(repo: repo)
                                 if repo == viewModel.repositories.last {
                                     viewModel.loadNextPage()
                                 }
                         }

                         if viewModel.isLoading {
                             ProgressView()
                                 .padding()
                         }
                     }
                 }
                 
                 final class RepoViewModel: ObservableObject {
                     let lastItemVisible = PassthroughSubject<Void, Never>()

                     init() {
                         lastItemVisible
                             .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
                             .sink { [weak self] in
                                 self?.loadNextPage()
                             }
                             .store(in: &cancellables)
                     }
                 }
*/
                
            
            .listStyle(PlainListStyle())
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
