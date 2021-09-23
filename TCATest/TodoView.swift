//
//  TodoView.swift
//  TCATest
//
//  Created by Kanz on 2021/09/23.
//

import SwiftUI
import ComposableArchitecture

struct TodoView: View {
    let store: Store<ToDo, ToDoAction>
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Button {
                    viewStore.send(.checkBoxToggled)
                } label: {
                    Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
                }
                .buttonStyle(.plain)

                TextField(
                    "Untitled Todo",
                    text: viewStore.binding(get: \.description, send: ToDoAction.textFieldChanged)
                )
            }
            .foregroundColor(viewStore.isComplete ? .gray : nil)
        }
    }
}

