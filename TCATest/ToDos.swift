//
//  ToDos.swift
//  TCATest
//
//  Created by Kanz on 2021/09/23.
//

import ComposableArchitecture
import SwiftUI

enum Filter: LocalizedStringKey, CaseIterable, Hashable {
case all = "All"
case active = "Active"
case completed = "Completed"
}

struct AppState: Equatable {
    var editMode: EditMode = .inactive
    var filter: Filter = .all
    var todos: IdentifiedArrayOf<ToDo> = []
    
    var filteredTodos: IdentifiedArrayOf<ToDo> {
        switch filter {
        case .all:
            return self.todos
        case .active:
            return self.todos.filter { $0.isComplete == false }
        case .completed:
            return self.todos.filter(\.isComplete)
        }
    }
}

enum AppAction: Equatable {
    case addToDoButtonTapped
    case clearCompletedButtonTapped
    case delete(IndexSet)
    case editModeChanged(EditMode)
    case filterPicked(Filter)
    case move(IndexSet, Int)
    case sortCompletedTodos
    case todo(id: ToDo.ID, action: ToDoAction)
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(
        state: \.todos,
        action: /AppAction.todo(id:action:),
        environment: { _ in ToDoEnvironment() }
    ),
    Reducer { state, action, environment in
        switch action {
        case .addToDoButtonTapped:
            state.todos.insert(ToDo(id: environment.uuid()), at: 0)
            return .none
            
        case .clearCompletedButtonTapped:
            state.todos.removeAll(where: \.isComplete)
            return .none
            
        case .delete(let indexSet):
            state.todos.remove(atOffsets: indexSet)
            return .none
            
        case .editModeChanged(let editMode):
            state.editMode = editMode
            return .none
        
        case .filterPicked(let filter):
            state.filter = filter
            return .none
            
        case .move(let source, let destination):
            state.todos.move(fromOffsets: source, toOffset: destination)
            return Effect(value: .sortCompletedTodos)
                .delay(for: .milliseconds(100), scheduler: environment.mainQueue)
                .eraseToEffect()
            
        case .sortCompletedTodos:
            state.todos.sort { $1.isComplete && $0.isComplete == false }
            return .none
            
        case .todo(id: let id, action: let action):
            struct TodoCompletionId: Hashable {}
            return Effect(value: .sortCompletedTodos)
                .debounce(id: TodoCompletionId(), for: 1, scheduler: environment.mainQueue.animation())
        }
    }
).debug()
