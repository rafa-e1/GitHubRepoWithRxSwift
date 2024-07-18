//
//  RepositoryListViewModel.swift
//  GitHubRepo
//
//  Created by RAFA on 7/18/24.
//

import RxCocoa
import RxSwift

class RepositoryListViewModel {
    
    let repositories: BehaviorSubject<[Repository]> = BehaviorSubject(value: [])
    private let disposeBag = DisposeBag()
    
    func fetchRepositories(of organization: String) {
        Observable.from([organization])
            .map { organization -> URL? in
                URL(string: "https://api.github.com/orgs/\(organization)/repos")
            }
            .compactMap { $0 }  // nil을 제거하여 URL 인스턴스만 전달
            .map { URLRequest(url: $0) }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                URLSession.shared.rx.response(request: request)
            }
            .filter { response, _ in
                200..<300 ~= response.statusCode
            }
            .map { _, data -> [Repository] in
                do {
                    return try JSONDecoder().decode([Repository].self, from: data)
                } catch {
                    print("Error decoding data: \(error)")
                    return []
                }
            }
            .bind(to: repositories)
            .disposed(by: disposeBag)
    }
}
