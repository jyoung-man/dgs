//
//  GitHubLoginViewModel.swift
//  Daou-Github-Search
//
//  Created by 박재영 on 11/16/25.
//

import SwiftUI
import Combine

final class GitHubLoginViewModel: ObservableObject {
    
    @Published private(set) var repositories = [Repository]()
    
    private var myRepoCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }
    
    deinit {
        myRepoCancellable?.cancel()
    }
    
    private let client: GitHubClientProtocol
    
    init(client: GitHubClientProtocol) {
        self.client = client
    }

    func fetchMyStarred() {
        print("fetch my starred")
        myRepoCancellable = client.myStarredRepositories()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Starred list error: \(error)")
                }
            } receiveValue: { [weak self] repos in
                self?.repositories = repos
                print("starred repositories = \(repos)")
            }
    }
    func getStaredRepo() {
        let request: URLRequest
        do {
            request = try GitHubAPI.myStarredRepositories.asURLRequest()
        } catch {
            repositories = []
            return
        }
        
        myRepoCancellable = URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: RepositoryResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .catch { error -> Just<[Repository]> in
                return Just([])
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.repositories = items
                print("starred repositories = \(items)")

            }
    }
}
