//
//  CalorieTrackerApp.swift
//  CalorieTracker
//
//  Created by Mohammed Fareed on 2/26/25.
//

import SwiftData
import SwiftUI

@main
struct CalorieTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
