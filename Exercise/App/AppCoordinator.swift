//
//  AppCoordinator.swift
//  Exercise
//

import UIKit

@MainActor
final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    
    private let window: UIWindow
    private var childCoordinator: Coordinator?
    private var rootNavigationController: UINavigationController?
    private let todoListViewModel = TodoListViewModel()
    private var todoCountTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    init(window: UIWindow) {
        self.window = window
    }
    
    deinit {
        todoCountTask?.cancel()
    }
    
    func start() {
        guard rootNavigationController == nil else { return }
        
        let viewController = ViewController()
        viewController.onAbout = { [weak self] in
            self?.goToAbout()
        }
        viewController.onTodo = { [weak self] in
            self?.goToTodoList()
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        rootNavigationController = navigationController
        
        todoCountTask?.cancel()
        todoCountTask = Task { @MainActor [weak self, weak viewController] in
            guard let self, let viewController else { return }
            for await count in self.todoListViewModel.$items.values.map(\.count) {
                viewController.updateTodoCount(count)
            }
        }
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Private Methods
    
    private func goToAbout() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = AboutCoordinator(
            navigationController: navigationController,
            onFinish: { [weak self, weak navigationController] in
                navigationController?.dismiss(animated: true)
                self?.childCoordinator = nil
            }
        )
        childCoordinator = coordinator
        coordinator.start()
        rootNavigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    private func goToTodoList() {
        guard childCoordinator == nil else { return }
        guard let navigationController = rootNavigationController else { return }
        
        let coordinator = TodoCoordinator(
            navigationController: navigationController,
            todoListViewModel: todoListViewModel,
            onFinish: { [weak self] in
                self?.childCoordinator = nil
            }
        )
        childCoordinator = coordinator
        coordinator.start()
    }
}
