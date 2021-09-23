//
//  AppView.swift
//  TCATest
//
//  Created by Kanz on 2021/09/23.
//

import SwiftUI

import ComposableArchitecture

struct ViewState: Equatable {
    let editMode: EditMode
    let filter: Filter
    let isClearCompletedButtonDisabled: Bool
    
    init(state: AppState) {
        self.editMode = state.editMode
        self.filter = state.filter
        self.isClearCompletedButtonDisabled = !state.todos.contains(where: \.isComplete)
    }
}

struct AppView: View {
    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init(state:)))
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Picker(
                    "Filter",
                    selection: self.viewStore.binding(get: \.filter, send: AppAction.filterPicked)
                ) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.rawValue)
                            .tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                List {
                    ForEachStore(
                        self.store.scope(state: \.filteredTodos, action: AppAction.todo(id:action:)),
                        content: TodoView.init(store:)
                    )
                        .onDelete { self.viewStore.send(.delete($0)) }
                        .onMove { self.viewStore.send(.move($0, $1)) }
                }
                
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 20) {
                        EditButton()
                        
                        Button("Clear Completed") {
                            self.viewStore.send(.clearCompletedButtonTapped, animation: .default)
                        }
                        .disabled(self.viewStore.isClearCompletedButtonDisabled)
                        
                        Button("Add Todo") {
                            self.viewStore.send(.addToDoButtonTapped, animation: .default)
                        }
                    }
                }
            }
            .environment(
                \.editMode,
                 self.viewStore.binding(get: \.editMode, send: AppAction.editModeChanged)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

extension IdentifiedArray where ID == ToDo.ID, Element == ToDo {
    static let mock: Self = [
        ToDo(
            id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEDDEADBEEF")!,
            description: "Check Mail",
            isComplete: false
        ),
        ToDo(
            id: UUID(uuidString: "CAFEBEEF-CAFE-BEEF-CAFE-BEEFCAFEBEEF")!,
            description: "Buy Milk",
            isComplete: false
        ),
        ToDo(
            id: UUID(uuidString: "D00DCAFE-D00D-CAFE-D00D-CAFED00DCAFE")!,
            description: "Call Mom",
            isComplete: true
        ),
    ]
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(todos: .mock),
                reducer: appReducer,
                environment: AppEnvironment(
                    mainQueue: .main,
                    uuid: UUID.init
                )
            )
        )
    }
}
