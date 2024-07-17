//
//  RepositoryListViewController.swift
//  GitHubRepo
//
//  Created by RAFA on 7/17/24.
//

import UIKit

import RxCocoa
import RxSwift
import Then

class RepositoryListViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let organization = "Apple"
    private let repositories = BehaviorSubject<[Repository]>(value: [])
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
    }
    
    // MARK: - SetupUI
    
    private func setupUI() {
        title = organization + " Repositories"
        tableView.register(RepositoryListViewCell.self, forCellReuseIdentifier: "RepositoryListViewCell")
        tableView.rowHeight = 140
    }
    
    private func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        self.refreshControl = refreshControl
        
        refreshControl.do {
            $0.backgroundColor = .white
            $0.backgroundColor = .white
            $0.tintColor = .darkGray
            $0.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
            $0.addTarget(self, action: #selector(updateRepositoryData), for: .valueChanged)
        }
    }
    
    // MARK: - Actions
    
    @objc private func updateRepositoryData() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        }
    }
    
    // MARK: - API
    
    private func fetchRepositories(of organization: String) {
        Observable.from([organization])
            .map { organization -> URL? in
                guard let url = URL(string: "https://api.github.com/orgs/\(organization)/repos") else {
                    return nil
                }
                return url
            }
            .compactMap { $0 }
            .map { url -> URLRequest in
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return request
            }
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]]
                else {
                    return []
                }
                return result
            }
            .filter { result in
                return result.count > 0
            }
            .map { objects in
                return objects.compactMap { dict -> Repository? in
                    guard let id = dict["id"] as? Int,
                          let name = dict["name"] as? String,
                          let description = dict["description"] as? String,
                          let stargazersCount = dict["stargazers_count"] as? Int,
                          let language = dict["language"] as? String
                    else {
                        return nil
                    }
                    return Repository(
                        id: id,
                        name: name,
                        description: description,
                        stargazersCount: stargazersCount,
                        language: language
                    )
                }
            }
            .subscribe(onNext: { [weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try repositories.value().count
        } catch {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RepositoryListViewCell",
            for: indexPath
        ) as? RepositoryListViewCell else {
            return UITableViewCell()
        }
        var currentRepo: Repository? {
            do {
                return try repositories.value()[indexPath.row]
            } catch {
                return nil
            }
        }
        cell.repository = currentRepo
        return cell
    }
}
