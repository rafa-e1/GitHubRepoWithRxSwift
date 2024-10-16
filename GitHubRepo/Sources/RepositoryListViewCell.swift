//
//  RepositoryListViewCell.swift
//  GitHubRepo
//
//  Created by RAFA on 7/17/24.
//

import UIKit

import SnapKit
import Then

class RepositoryListViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var repository: Repository?
    
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let starImageView = UIImageView()
    let starLabel = UILabel()
    let languageLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
        configure()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        [nameLabel, descriptionLabel, starImageView, starLabel, languageLabel].forEach {
            contentView.addSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(18)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.horizontalEdges.equalTo(nameLabel)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionLabel)
            $0.bottom.equalToSuperview().inset(18)
            $0.size.equalTo(20)
        }
        
        starLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        
        languageLabel.snp.makeConstraints {
            $0.centerY.equalTo(starLabel)
            $0.leading.equalTo(starLabel.snp.trailing).offset(12)
        }
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let repository = repository else { return }
        nameLabel.do {
            $0.text = repository.name
            $0.font = .systemFont(ofSize: 15, weight: .bold)
        }
        
        descriptionLabel.do {
            $0.numberOfLines = 2
            $0.text = repository.description
            $0.font = .systemFont(ofSize: 15)
        }
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.do {
            $0.text = "\(repository.stargazersCount)"
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .gray
        }
        
        languageLabel.do {
            $0.text = repository.language
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .gray
        }
    }
}
