//
//  SearchViewModel.swift
//  Daou-Github-Search
//
//  Created by 박재영 on 11/16/25.
//

import SwiftUI
import Combine

final class SearchViewModel:
    ObservableObject {
    
    @Published var keyword = "rxswift"
    @Published private(set) var repositories = [Repository]()
    
    
    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    deinit {
        searchCancellable?.cancel()
    }
    
    func search() {
        guard !keyword.isEmpty else {
            return repositories = []
        }
        
        let request: URLRequest
        do {
            request = try GitHubAPI.repositories(query: keyword, perPage: 100, page: 1).asURLRequest()
        } catch {
            return repositories = []
        }
        searchCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: RepositoryResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .catch { error -> Just<[Repository]> in
                print("Search API error:", error)
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.repositories = items
            }
    }
}
