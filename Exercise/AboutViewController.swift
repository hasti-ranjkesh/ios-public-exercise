//
//  AboutViewController.swift
//  Exercise
//

import UIKit

class AboutViewController: UIViewController {
    var onClose: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func closeTap() {
        onClose?()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        
        let label = UILabel()
        label.numberOfLines = Constants.numberOfLines
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Public is where serious investors build their wealth. Grow your cash with higher yields and build a multi-asset portfolio for the long haul."
        label.textColor = .black
        label.textAlignment = .center
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constants.marging),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constants.marging),
            label.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
        
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .close, target: self, action: #selector(closeTap))
        navigationItem.title = "About"
    }
}

extension AboutViewController {
    enum Constants {
        static let numberOfLines: Int = 0
        static let marging: CGFloat = 32
    }
}
