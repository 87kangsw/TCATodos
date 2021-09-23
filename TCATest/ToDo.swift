//
//  ToDo.swift
//  TCATest
//
//  Created by Kanz on 2021/09/23.
//

import Foundation
import SwiftUI

import ComposableArchitecture

// MARK: - Model (data)
struct ToDo: Equatable, Identifiable {
    let id: UUID
    var description: String = ""
    var isComplete: Bool = false
}

// MARK: - Action
enum ToDoAction: Equatable {
    case checkBoxToggled
    case textFieldChanged(String)
}

// MARK: - Environment
struct ToDoEnvironment {}

// MARK: - Reducer

let todoReducer = Reducer<ToDo, ToDoAction, ToDoEnvironment> { todo, action, _ in
    switch action {
    case .checkBoxToggled:
        todo.isComplete.toggle()
        return .none
    case .textFieldChanged(let description):
        todo.description = description
        return .none
    }
}.debug()
