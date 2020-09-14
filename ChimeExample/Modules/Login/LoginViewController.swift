//
//  LoginViewController.swift
//  ChimeExample
//
//  Created by Yanik Simpson on 9/13/20.
//  Copyright © 2020 Yanik Simpson. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    // Dependencies
    let controller = LoginModuleController()
    
    // Views
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Jane Appleseed"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    override var inputAccessoryView: UIView? {
        return makeLoginButton()
    }
    
    // View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        layoutContent()
        configureHandlers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    fileprivate func configureHandlers() {
        controller.invalidNameHandler = { [weak self] _ in
            let alertVC = UIAlertController(title: "Error", message: "Please enter a username", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertVC.addAction(cancelAction)
            self?.present(alertVC, animated: true, completion: nil)
        }
        controller.loginHandler = { [weak self] user in
            let homeViewController = HomeViewController()
            homeViewController.controller = HomeModuleController(user: user)
            let navVC = UINavigationController(rootViewController: homeViewController)
            navVC.modalPresentationStyle = .fullScreen
            self?.present(navVC, animated: true, completion: nil)
        }
    }
    
    // View Creation/Layout
    fileprivate func layoutContent() {
        let instructionsLabel = UILabel()
        instructionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        instructionsLabel.text = "Enter your name below"
        instructionsLabel.textColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [instructionsLabel, nameTextField])
        stackView.axis = .vertical
        stackView.spacing = 4
        
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -44).isActive = true
        
        makeValueProposition(bottomView: stackView)
    }
    
    fileprivate func makeValueProposition(bottomView: UIView) {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
        titleLabel.textAlignment = .center
        titleLabel.text = "TELE-MED"
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -42).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
    }
    
    fileprivate func makeLoginButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemBlue
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }
    
    // MARK: - Actions
    
    @objc fileprivate func handleLogin() {
        let username = nameTextField.text ?? ""
        controller.login(withUsername: username)
    }
}
