//
//  TodoCoordinator.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import UIKit
import SwiftUI

private final class TodoListHostingController: UIHostingController<TodoListScreen> {
    var onDeinit: (() -> Void)?

    deinit {
        onDeinit?()
    }
}

final class TodoCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let todoListViewModel: TodoListViewModel
    private let onFinish: (() -> Void)?

    init(
        navigationController: UINavigationController,
        todoListViewModel: TodoListViewModel,
        onFinish: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.todoListViewModel = todoListViewModel
        self.onFinish = onFinish
    }

    func start() {
        let hostingController = TodoListHostingController(rootView: TodoListScreen(viewModel: todoListViewModel))
        hostingController.title = "TO-DO"
        hostingController.onDeinit = { [weak self] in
            self?.onFinish?()
        }
        hostingController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(showAddTaskAlertController)
        )
        navigationController.pushViewController(hostingController, animated: true)
    }
    
    // MARK: Private Methods
    
    @objc private func showAddTaskAlertController() {
        let alertController = UIAlertController(title: "New Task", message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Task name"
            textField.addTarget(self, action: #selector(self.taskNameTextDidChange(_:)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            guard
                let self,
                let taskName = alertController?.textFields?.first?.text
            else { return }
            
            Task { @MainActor [weak self] in
                self?.todoListViewModel.addTask(named: taskName)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        navigationController.present(alertController, animated: true)
    }

    @objc private func taskNameTextDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count > Constants.maxTaskNameLength else { return }
        textField.text = String(text.prefix(Constants.maxTaskNameLength))
    }
}

extension TodoCoordinator {
    enum Constants {
        static let maxTaskNameLength = 50
    }
}
