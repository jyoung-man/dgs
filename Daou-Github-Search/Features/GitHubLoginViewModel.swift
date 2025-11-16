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
    
    private var token: String?
    
    deinit {
        myRepoCancellable?.cancel()
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
    
    func getStaredRepo() {
        let request: URLRequest
        do {
            request = try GitHubAPI.myStarredRepositories(accessToken: self.token ?? "").asURLRequest()
        } catch {
            repositories = []
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
                self?.repositories = items
                print("starred repositories = \(items)")
            }
    }
    
    func toggleStar(for repository: Repository) {
        guard let index = repositories.firstIndex(where: { $0.id == repository.id }) else { return }

        let endpoint: GitHubAPI
        if repository.isStarred {
            endpoint = .unstar(owner: repository.owner.name, repository: repository.name)
        } else {
            endpoint = .star(owner: repository.owner.name, repository: repository.name)
        }

        do {
            let request = try endpoint.asURLRequest()
            myRepoCancellable = URLSession.shared.dataTaskPublisher(for: request)
                .map { _ in repository.isStarred }
                .catch { error -> Just<Bool> in
                    return Just(false)
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.repositories[index].isStarred.toggle()
                }
        } catch {
            print("Star/Unstar request failed:", error)
        }
    }
}

