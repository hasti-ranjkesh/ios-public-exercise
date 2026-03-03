//
//  ViewController.swift
//  Exercise
//

import UIKit

final class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var onAbout: (() -> Void)?
    var onTodo: (() -> Void)?

    private let todoButton = UIButton(type: .system)
    private let aboutButton = UIButton(type: .system)

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: - Public Method
    
    func updateTodoCount(_ count: Int) {
        todoButton.setTitle("TO-DO: \(count)", for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .white

        todoButton.translatesAutoresizingMaskIntoConstraints = false
        todoButton.setTitle("TO-DO: 0", for: .normal)
        todoButton.accessibilityLabel = "TO-DO List"
        todoButton.setTitleColor(.systemBlue, for: .normal)
        todoButton.addTarget(self, action: #selector(todoButtonTap), for: .touchUpInside)

        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        aboutButton.setTitle("About", for: .normal)
        aboutButton.accessibilityLabel = "About Public"
        aboutButton.setTitleColor(.systemBlue, for: .normal)
        aboutButton.addTarget(self, action: #selector(aboutButtonTap), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [todoButton, aboutButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Constants.margin

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    @objc private func todoButtonTap() {
        onTodo?()
    }

    @objc private func aboutButtonTap() {
        onAbout?()
    }
}

// MARK: - UI Constants

extension ViewController {
    enum Constants {
        static let margin: CGFloat = 16
    }
}
