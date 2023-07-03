//
//  Slot_MachineApp.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/3/23.
//

import SwiftUI

@main
struct Slot_MachineApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
