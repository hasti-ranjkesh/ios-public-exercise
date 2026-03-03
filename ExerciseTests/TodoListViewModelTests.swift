import Foundation
import Testing
@testable import Exercise

struct TodoListViewModelTests {
    @Test("addTask trims input and marks item as saved after successful save")
    @MainActor
    func addTaskTrimsAndSaves() async {
        let viewModel = TodoListViewModel(
            taskSaver: StubTaskSaver(result: true, delayNanoseconds: 50_000_000)
        )

        viewModel.addTask(named: "  Buy milk  ")

        #expect(viewModel.items.count == 1)
        #expect(viewModel.items[0].title == "Buy milk")
        #expect(viewModel.items[0].status == .saving)

        let didSave = await waitUntil {
            viewModel.items.first?.status == .saved
        }
        #expect(didSave)
    }

    @Test("addTask ignores empty or whitespace-only names")
    @MainActor
    func addTaskIgnoresEmptyNames() {
        let viewModel = TodoListViewModel(taskSaver: StubTaskSaver(result: true))

        viewModel.addTask(named: "")
        viewModel.addTask(named: "   \n\t  ")

        #expect(viewModel.items.isEmpty)
    }

    @Test("failed saves are removed after delay")
    @MainActor
    func failedSaveRemovesItemAfterDelay() async {
        let viewModel = TodoListViewModel(
            taskSaver: StubTaskSaver(result: false),
            failedRemovalDelayNanoseconds: 20_000_000
        )

        viewModel.addTask(named: "Will fail")

        let didBecomeFailed = await waitUntil {
            viewModel.items.first?.status == .failed
        }
        #expect(didBecomeFailed)

        let didRemove = await waitUntil {
            viewModel.items.isEmpty
        }
        #expect(didRemove)
    }

    @Test("deleteTask removes only saved items")
    @MainActor
    func deleteTaskRemovesOnlySavedItems() {
        let savedID = UUID()
        let savingID = UUID()
        let failedID = UUID()
        let viewModel = TodoListViewModel(
            items: [
                TodoItem(id: savedID, title: "Saved", status: .saved),
                TodoItem(id: savingID, title: "Saving", status: .saving),
                TodoItem(id: failedID, title: "Failed", status: .failed)
            ],
            taskSaver: StubTaskSaver(result: true)
        )

        viewModel.deleteTask(id: savingID)
        viewModel.deleteTask(id: failedID)
        #expect(viewModel.items.count == 3)

        viewModel.deleteTask(id: savedID)
        #expect(viewModel.items.count == 2)
        #expect(viewModel.items.contains { $0.id == savingID })
        #expect(viewModel.items.contains { $0.id == failedID })
    }

    @MainActor
    private func waitUntil(
        timeoutNanoseconds: UInt64 = 1_000_000_000,
        pollIntervalNanoseconds: UInt64 = 10_000_000,
        condition: @MainActor () -> Bool
    ) async -> Bool {
        let iterations = Int(timeoutNanoseconds / pollIntervalNanoseconds)

        for _ in 0..<iterations {
            if condition() {
                return true
            }
            try? await Task.sleep(nanoseconds: pollIntervalNanoseconds)
        }

        return condition()
    }
}

private struct StubTaskSaver: TodoTaskSaving {
    let result: Bool
    let delayNanoseconds: UInt64

    init(
        result: Bool,
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

    func simulateSave() async -> Bool {
        if delayNanoseconds > 0 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        return result
    }
}
