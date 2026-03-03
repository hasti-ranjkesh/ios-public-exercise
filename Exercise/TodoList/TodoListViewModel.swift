//
//  TodoListViewModel.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import Foundation
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    
    @Published private(set) var items: [TodoItem]
    
    init(items: [TodoItem] = []) {
        self.items = items
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
            let delayMilliseconds = Int.random(in: 500...5000)
            let delayNanoseconds = UInt64(delayMilliseconds) * 1_000_000
            try? await Task.sleep(nanoseconds: delayNanoseconds)
            
            self?.finishSave(for: id)
        }
    }
    
    private func finishSave(for id: UUID) {
        guard let row = items.firstIndex(where: { $0.id == id }) else { return }
        
        let didSucceed = Double.random(in: 0...1) < 0.75
        if didSucceed {
            items[row].status = .saved
            return
        }
        
        items[row].status = .failed
        
        Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard let self else { return }
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
