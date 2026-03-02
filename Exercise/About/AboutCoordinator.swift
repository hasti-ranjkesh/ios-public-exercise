//
//  AboutCoordinator.swift
//  Exercise
//

import UIKit

final class AboutCoordinator: Coordinator {
	let navigationController: UINavigationController
	let onFinish: (() -> Void)?

	init(
        navigationController: UINavigationController,
        onFinish: (() -> Void)? = nil
    ) {
		self.navigationController = navigationController
		self.onFinish = onFinish
	}

	func start() {
		let viewController = AboutViewController()
		viewController.onClose = { [weak self] in
			self?.close()
		}
		navigationController.pushViewController(viewController, animated: false)
	}

	private func close() {
		onFinish?()
	}
}
