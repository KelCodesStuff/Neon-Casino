//
//  ContentView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    
    // MARK: - Properties
    @State private var credits = 1000
    @State private var showInfoView = false
    @State private var showGameOverModal = false

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
                .blur(radius:  showGameOverModal ? 5 : 0 , opaque: false)
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
