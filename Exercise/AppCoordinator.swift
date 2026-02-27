//
//  AppCoordinator.swift
//  Exercise
//

import UIKit
import SwiftUI
import Combine

@MainActor
class AppCoordinator {
    private let window: UIWindow
    
    private var childCoordinator: MainCoordinator?
    private var rootNavigationController: UINavigationController?
    private weak var homeViewController: ViewController?
    private let todoListViewModel = TodoListViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let viewController = ViewController()
        viewController.onAbout = { [weak self] in
            self?.goToAbout()
        }
        viewController.onTodo = { [weak self] in
            Task { @MainActor in
                self?.goToTodoList()
            }
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        rootNavigationController = navigationController
        homeViewController = viewController
        
        todoListViewModel.$items
            .sink { [weak self] items in
                self?.homeViewController?.updateTodoCount(items.count)
            }
            .store(in: &cancellables)
        
        viewController.updateTodoCount(todoListViewModel.items.count)
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func goToAbout() {
        let navigationController = UINavigationController()
        navigationController.modalPresentationStyle = .fullScreen
        let coordinator = MainCoordinator(
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
    
    @MainActor func goToTodoList() {
        let hostingController = UIHostingController(rootView: TodoListScreen(viewModel: todoListViewModel))
        hostingController.title = "TO-DO"
        hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: nil,
            action: nil
        )
        
        hostingController.navigationItem.rightBarButtonItem?.primaryAction = UIAction { [weak self, weak hostingController] _ in
            guard
                let self,
                let vc = hostingController
            else { return }
            self.presentTodoAlert(on: vc)
        }
        
        rootNavigationController?.pushViewController(hostingController, animated: true)
    }
    
    // MARK: - TO-DO flow helpers
    
    private func presentTodoAlert(on presenter: UIViewController) {
        let alertController = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Task name"
            textField.addTarget(self, action: #selector(self.todoAlertTextChanged(_:)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            guard
                let self,
                let taskName = alertController?.textFields?.first?.text
            else { return }
            
            Task { @MainActor in
                self.todoListViewModel.addTask(named: taskName)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        presenter.present(alertController, animated: true)
    }
    
    @objc private func todoAlertTextChanged(_ textField: UITextField) {
        let text = textField.text ?? ""
        if text.count > TodoListViewModel.maxTaskNameLength {
            textField.text = String(text.prefix(TodoListViewModel.maxTaskNameLength))
        }
    }
}
