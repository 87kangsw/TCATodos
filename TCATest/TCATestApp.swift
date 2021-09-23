//
//  TCATestApp.swift
//  TCATest
//
//  Created by Kanz on 2021/09/23.
//

import SwiftUI
import ComposableArchitecture

@main
struct TCATestApp: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppState(),
                    reducer: appReducer,
                    environment: AppEnvironment(
                        mainQueue: .main,
                        uuid: UUID.init
                    )
                )
            )
        }
    }
}
