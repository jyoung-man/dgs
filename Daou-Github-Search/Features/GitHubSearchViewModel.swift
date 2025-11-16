//
//  GitHubSearchViewModel.swift
//  Daou-Github-Search
//
//  Created by 박재영 on 11/16/25.
//

import SwiftUI
import Combine

final class GitHubSearchViewModel: ObservableObject {
    @Published private(set) var totalRepositories = [Repository]()
    @Published private(set) var starredRepositories = [Repository]()
    @Published var keyword = ""
    @Published var page = 1
    @Published var isLoading = false
    @Published var totalCount: Int?
    
    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    private var myRepoCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    private var toggleCancellable: Cancellable?

    private var token: String?
    
    deinit {
        myRepoCancellable?.cancel()
        searchCancellable?.cancel()
        toggleCancellable?.cancel()
    }
    
    private var client: GitHubClientProtocol
    
    init(client: GitHubClientProtocol, loginService: GitHubLoginService) {
        self.client = client
        myRepoCancellable = loginService.loginCompletedPublisher
            .sink { [weak self] in
                guard let self = self else { return }
                // keychainService에서 token을 꺼내서 client를 업데이트
                self.token = loginService.getAccessToken()
                self.client = GitHubClient(session: .default)
            }
    }
    
    func search(reset: Bool = true, completion: (() -> Void)? = nil) {
        if reset {
            page = 1
            totalCount = 0
            totalRepositories = []
        }
        
        guard !keyword.isEmpty else {
            totalRepositories = []
            totalCount = 0
            return
        }
        
        let request: URLRequest
        do {
            request = try GitHubAPI.repositories(query: keyword, perPage: 15, page: page).asURLRequest()
        } catch {
            totalRepositories = []
            return
        }
        searchCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: RepositoryResponse.self, decoder: JSONDecoder())
            .catch { error -> Just<RepositoryResponse> in
                if let data = error as? DecodingError {
                    // 마지막 페이지: total_count 없음 → 빈 Response 반환
                    return Just(RepositoryResponse(total_count: self.totalRepositories.count, incomplete_results: true, items: []))
                }
                print("Search API error:", error)
                return Just(RepositoryResponse(total_count: 0, incomplete_results: true, items: []))
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] response in
                if reset {
                    self?.totalRepositories = response.items
                } else {
                    self?.totalRepositories.append(contentsOf: response.items)
                }
                self?.totalCount = response.total_count
                print("total count = \(response.total_count)")
                completion?()
            }
    }
    
    func loadNextPage() {
        guard !isLoading, totalRepositories.count < totalCount ?? 0 else { return }
        isLoading = true
        page += 1
        search(reset: false) { [weak self] in
            self?.isLoading = false
        }
    }

    func getStaredRepo() {
        let request: URLRequest
        do {
            request = try GitHubAPI.myStarredRepositories(accessToken: self.token ?? "").asURLRequest()
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let httpResponse = response as? HTTPURLResponse else { return }

                if let limit = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit"),
                   let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining"),
                   let reset = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset") {
                    print("RateLimit: \(limit), Remaining: \(remaining), Reset: \(reset)")
                }

                if let data = data {
                    print(String(data: data, encoding: .utf8) ?? "")
                }
            }.resume()

        } catch {
            starredRepositories = []
            return
        }
        
        myRepoCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: [Repository].self, decoder: JSONDecoder())
            .catch { error -> Just<[Repository]> in
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.starredRepositories = items
                print("starred repositories = \(items)")
            }
    }
    
    func toggleStar(for repository: Repository) {
        print("toggled star")
        guard let index = starredRepositories.firstIndex(where: { $0.id == repository.id }) else { return }

        let endpoint: GitHubAPI
        if repository.isStarred ?? false {
            endpoint = .unstar(owner: repository.owner.name, repository: repository.name)
        } else {
            endpoint = .star(owner: repository.owner.name, repository: repository.name)
        }

        do {
            let request = try endpoint.asURLRequest()
            myRepoCancellable = URLSession.shared.dataTaskPublisher(for: request)
                .map { _ in }
                .catch { error -> Just<Void> in Just(()) }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.getStaredRepo()
                    
                    // 전체 검색 목록에서도 isStarred 업데이트
                    if let searchIndex = self?.totalRepositories.firstIndex(where: { $0.id == repository.id }) {
                        self?.totalRepositories[searchIndex].isStarred?.toggle()
                    }
                }
        } catch {
            print("Star/Unstar request failed:", error)
        }
    }

}
