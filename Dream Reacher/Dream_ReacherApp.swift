//
//  Dream_ReacherApp.swift
//  Dream Reacher
//
//  Created by Julia Kansbod on 2022-12-11.
//

import SwiftUI

@main
struct Dream_ReacherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
