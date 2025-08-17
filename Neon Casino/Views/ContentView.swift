//
//  ContentView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @State private var showInfoView = false

    var body: some View {
        ZStack {
            // Background
            BackgroundView()
            VStack(alignment: .center, spacing: 5) {
                LogoView()

                Spacer()

                // Slot Machine
                SlotMachineView()

            }
                // MARK: - Nav bar buttons
                .overlay(
                    // Info button
                    Button(action: {
                        self.showInfoView = true
                    }) {
                        Image(systemName: "info.circle")
                    }
                    .modifier(ButtonModifier()), alignment: .topTrailing
                )
                .padding()
                .frame(maxWidth: 720)
        }
        .sheet(isPresented: $showInfoView) {
            InfoView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
