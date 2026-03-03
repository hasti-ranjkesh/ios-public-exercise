//
//  TodoCoordinator.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import UIKit
import SwiftUI

/// A hosting controller that wraps `TodoListScreen` and exposes a deinitialization callback.
/// The coordinator needs to be notified when the pushed SwiftUI screen is released from memory.
private final class TodoListHostingController: UIHostingController<TodoListScreen> {

    /// Set this to perform cleanup or notify external owners that the screen lifecycle ended.
    var onDeinit: (() -> Void)?
    
    /// Calls `onDeinit` just before the hosting controller is deallocated.
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
        hostingController.title = L10n.todoListTitle
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
        let alertController = UIAlertController(title: L10n.newTaskAlertTitle, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = L10n.taskNamePlaceholder
            textField.addTarget(self, action: #selector(self.taskNameTextDidChange(_:)), for: .editingChanged)
        }
        
        let cancelAction = UIAlertAction(title: L10n.cancelButtonTitle, style: .cancel)
        let saveAction = UIAlertAction(title: L10n.saveButtonTitle, style: .default) { [weak self, weak alertController] _ in
            guard
                let self,
                let taskName = alertController?.textFields?.first?.text
            else { return }

            addTaskOnMainActor(named: taskName)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        navigationController.present(alertController, animated: true)
    }
    
    /// Adds a new task from the alert flow on the main actor.
    ///
    /// UIKit alert actions may execute outside the main-actor isolation of SwiftUI state.
    /// This helper guarantees `TodoListViewModel` mutation happens on the main actor.
    ///
    /// - Parameter taskName: The validated task name entered by the user.
    private func addTaskOnMainActor(named taskName: String) {
        Task { @MainActor [weak self] in
            self?.todoListViewModel.addTask(named: taskName)
        }
    }

    @objc private func taskNameTextDidChange(_ textField: UITextField) {
        guard let text = textField.text, text.count > Constants.maxTaskNameLength else { return }
        textField.text = String(text.prefix(Constants.maxTaskNameLength))
    }
}

// MARK: - UI Constants

extension TodoCoordinator {
    enum Constants {
        static let maxTaskNameLength = 50
    }
}

// MARK: - localization

extension TodoCoordinator {
    enum L10n {
        static let todoListTitle = NSLocalizedString("TO-DO", comment: "Todo list screen title")
        static let newTaskAlertTitle = NSLocalizedString("New Task", comment: "New task alert title")
        static let taskNamePlaceholder = NSLocalizedString("Task name", comment: "Task name input placeholder")
        static let cancelButtonTitle = NSLocalizedString("Cancel", comment: "Cancel button title")
        static let saveButtonTitle = NSLocalizedString("Save", comment: "Save button title")
    }
}
