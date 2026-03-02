//
//  TodoItem.swift
//  Exercise
//
//  Created by Hasti on 27/02/2026.
//

import Foundation

struct TodoItem {
    let id: UUID
    let title: String
    var status: TodoItemStatus
    
    init(
        id: UUID = UUID(),
        title: String,
        status: TodoItemStatus
    ) {
        self.id = id
        self.title = title
        self.status = status
    }
}
