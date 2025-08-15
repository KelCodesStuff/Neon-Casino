//
//  InfoView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct InfoView: View {
    
    // MARK: - Principal Properties
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            LogoView()
            Spacer()
            Form {
                // Pay table
                Section(header: Text("Pay Table")) {
                    HStack {
                        Image("win-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("win-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("win-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Jackpot")
                    }
                    HStack {
                        Image("money-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("money-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("money-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("500 money")
                    }
                    HStack {
                        Image("jewel-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("jewel-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("jewel-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("400 money")
                    }
                    HStack {
                        Image("crown-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("crown-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("crown-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("300 money")
                    }
                    HStack {
                        Image("spade-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("spade-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("spade-symbol")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("200 money")
                    }
                }
                // About
                Section(header: Text("Information"), footer: Text("")) {
                    KeyValueRow("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/privacy-policy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                            .foregroundColor(Color.green)
                    }
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/terms-of-service")!) {
                        Label("Terms of Service", systemImage: "note.text")
                            .foregroundColor(Color.green)
                    }
                    Link(destination: URL(string: "https://sites.google.com/view/onevrtech/end-user-license-agreement")!) {
                        Label("EULA", systemImage: "hand.thumbsup")
                            .foregroundColor(Color.green)
                    }
                }
            }
            .font(.system(.body, design: .rounded))
        }
        .padding(.top, 40)
        .overlay(
            Button(action: {
                audioPlayer?.stop()
                // Closing view
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle")
                    .font(.title)
            }
            .padding(.top, 30)
            .padding(.trailing, 20)
            .accentColor(Color.secondary), alignment: .topTrailing
        )
        .onAppear(perform: {
            playSound(sound: "background-music", type: "mp3")
        })
    }
    
    // Helper view for key-value pairs
    private func KeyValueRow(_ key: String, value: String?) -> some View {
        HStack {
            Text(key)
            Spacer()
            Text(value ?? "N/A")
        }
    }
}

struct FormRowView: View {
    var firstItem: String
    var secondItem: String
    
    var body: some View {
        HStack {
            Text(firstItem)
                .foregroundColor(Color.gray)
            Spacer()
            Text(secondItem)
        }
    }
}

struct InfoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView()
    }
}
