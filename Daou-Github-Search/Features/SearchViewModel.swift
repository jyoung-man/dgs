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
    
    @Published var keyword = ""
    @Published var page = 1
    @Published var isLoading = false
    @Published var totalCount: Int?
    @Published private(set) var repositories = [Repository]()
    
    
    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    deinit {
        searchCancellable?.cancel()
    }
    
    func search(reset: Bool = true, completion: (() -> Void)? = nil) {
        if reset {
            page = 1
            totalCount = 0
            repositories = []
        }
        
        guard !keyword.isEmpty else {
            repositories = []
            totalCount = 0
            return
        }
        
        let request: URLRequest
        do {
            request = try GitHubAPI.repositories(query: keyword, perPage: 15, page: page).asURLRequest()
        } catch {
            repositories = []
            return
        }
        searchCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: RepositoryResponse.self, decoder: JSONDecoder())
            .catch { error -> Just<RepositoryResponse> in
                if let data = error as? DecodingError {
                    // 마지막 페이지: total_count 없음 → 빈 Response 반환
                    return Just(RepositoryResponse(total_count: self.repositories.count, incomplete_results: true, items: []))
                }
                print("Search API error:", error)
                return Just(RepositoryResponse(total_count: 0, incomplete_results: true, items: []))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if reset {
                    self?.repositories = response.items
                } else {
                    self?.repositories.append(contentsOf: response.items)
                }
                self?.totalCount = response.total_count
                print("total count = \(response.total_count)")
                completion?()
            }
    }
    
    func loadNextPage() {
        guard !isLoading, repositories.count < totalCount ?? 0 else { return }
        isLoading = true
        page += 1
        search(reset: false) { [weak self] in
            self?.isLoading = false
        }
    }
}
