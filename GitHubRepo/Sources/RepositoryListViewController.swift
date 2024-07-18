//
//  RepositoryListViewController.swift
//  GitHubRepo
//
//  Created by RAFA on 7/17/24.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController: UITableViewController {
    
    // MARK: - Properties
    
    private let viewModel = RepositoryListViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRefreshControl()
        configure()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        title = "Apple Repositories"
        tableView.register(RepositoryListViewCell.self, forCellReuseIdentifier: "RepositoryListViewCell")
        tableView.rowHeight = 140
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.do {
            $0.backgroundColor = .white
            $0.tintColor = .darkGray
            $0.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        }
    }
    
    // MARK: - API
    
    private func configure() {
        tableView.dataSource = nil
        tableView.delegate = nil
        
        viewModel.repositories.bind(
            to: tableView.rx.items(
                cellIdentifier: "RepositoryListViewCell",
                cellType: RepositoryListViewCell.self
            )
        ) { _, repository, cell in
            cell.repository = repository
        }.disposed(by: disposeBag)
        
        refreshControl?.rx.controlEvent(.valueChanged)
            .bind { [weak self] _ in
                self?.viewModel.fetchRepositories(of: "Apple")
                self?.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try viewModel.repositories.value().count
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
                return try viewModel.repositories.value()[indexPath.row]
            } catch {
                return nil
            }
        }
        cell.repository = currentRepo
        return cell
    }
}
