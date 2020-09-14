//
//  HomeHeader.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit

final class HomeSectionHeaderView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let descriptionLabel = UILabel()
        descriptionLabel.textColor = .lightGray
        descriptionLabel.text = "See your scheduled appointments below."
        descriptionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 12
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -32).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12).isActive = true
    }
}
