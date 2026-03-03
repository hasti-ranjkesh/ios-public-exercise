//
//  TodoListViewModel.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import Foundation
import Combine

/// Abstraction for persisting a new todo task.
/// This keeps the view model decoupled from a concrete saving implementation,
/// which makes behavior easy to swap in tests or future networking code.
protocol TodoTaskSaving {
    /// Simulates an async save operation and returns whether it succeeded.
    func simulateSave() async -> Bool
}

/// Demo saver used by the exercise to mimic real-world backend variability.
/// It introduces a random delay and randomly succeeds/fails based on `successRate`.
struct RandomizedTodoTaskSaver: TodoTaskSaving {
    /// Simulated latency window to make UI state transitions visible.
    let delayRangeMilliseconds: ClosedRange<Int>
    /// Probability of success from 0.0 to 1.0.
    let successRate: Double
    
    init(
        delayRangeMilliseconds: ClosedRange<Int> = 500...5000,
        successRate: Double = 0.75
    ) {
        self.delayRangeMilliseconds = delayRangeMilliseconds
        self.successRate = successRate
    }
    
    func simulateSave() async -> Bool {
        let delayMilliseconds = Int.random(in: delayRangeMilliseconds)
        let delayNanoseconds = UInt64(delayMilliseconds) * 1_000_000
        // Sleep first to simulate network latency before returning a result.
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        return Double.random(in: 0...1) < successRate
    }
}

@MainActor
final class TodoListViewModel: ObservableObject {
    
    @Published private(set) var items: [TodoItem]
    private let taskSaver: TodoTaskSaving
    private let failedRemovalDelayNanoseconds: UInt64
    
    init(
        items: [TodoItem] = [],
        taskSaver: TodoTaskSaving = RandomizedTodoTaskSaver(),
        failedRemovalDelayNanoseconds: UInt64 = 1_000_000_000
    ) {
        self.items = items
        self.taskSaver = taskSaver
        self.failedRemovalDelayNanoseconds = failedRemovalDelayNanoseconds
    }
    
    func addTask(named taskName: String) {
        let trimmedTaskName = taskName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTaskName.isEmpty else { return }
        
        let newItem = TodoItem(title: trimmedTaskName, status: .saving)
        items.insert(newItem, at: 0)
        saveTask(for: newItem.id)
    }

    func deleteTask(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        deleteTask(at: index)
    }
    
    // MARK: - Private Methods
    
    private func saveTask(for id: UUID) {
        Task { [weak self] in
            guard let self else { return }
            let didSucceed = await taskSaver.simulateSave()
            finishSave(for: id, didSucceed: didSucceed)
        }
    }
    
    private func finishSave(for id: UUID, didSucceed: Bool) {
        guard let row = items.firstIndex(where: { $0.id == id }) else { return }
        
        if didSucceed {
            items[row].status = .saved
            return
        }
        
        items[row].status = .failed
        
        Task { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: self.failedRemovalDelayNanoseconds)
            guard let failedRow = items.firstIndex(where: { $0.id == id }) else { return }
            guard items[failedRow].status == .failed else { return }
            items.remove(at: failedRow)
        }
    }

    
    private func deleteTask(at index: Int) {
        guard items.indices.contains(index), items[index].status == .saved else { return }
        items.remove(at: index)
    }
}
