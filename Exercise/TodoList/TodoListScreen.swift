//
//  TodoListScreen.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import SwiftUI

struct TodoListScreen: View {
    @ObservedObject var viewModel: TodoListViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                HStack(spacing: 16) {
                    Text(item.title)
                        .foregroundStyle(textColor(for: item.status))
                    
                    Spacer()
                    
                    switch item.status {
                    case .saving:
                        ProgressView()
                    case .saved:
                        Button {
                            viewModel.deleteTask(id: item.id)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.primary)
                        }
                    case .failed:
                        EmptyView()
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func textColor(for status: TodoItemStatus) -> Color {
        switch status {
        case .saving, .saved:
            return .primary
        case .failed:
            return .red
        }
    }
}

