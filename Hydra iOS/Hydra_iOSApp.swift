//
//  Hydra_iOSApp.swift
//  Hydra iOS
//
//  Created by Jan Lecoutere on 06/10/2022.
//

import SwiftUI

@main
struct Hydra_iOSApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
