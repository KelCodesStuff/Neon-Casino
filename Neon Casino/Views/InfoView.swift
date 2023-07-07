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
                        Image("win")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("win")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("win")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("Jackpot")
                    }
                    HStack {
                        Image("money")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("money")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("money")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("500 credits")
                    }
                    HStack {
                        Image("jewel")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("jewel")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("jewel")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("400 credits")
                    }
                    HStack {
                        Image("seven")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("seven")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("seven")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("300 credits")
                    }
                    HStack {
                        Image("club")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("club")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Image("club")
                            .resizable()
                            .frame(width: 30, height: 30)
                        Text("200 credits")
                    }
                }
                // About
                Section(header: Text("About")) {
                    FormRowView(firstItem: "Platforms", secondItem: "iOS, iPadOS")
                    FormRowView(firstItem: "Version", secondItem: "1.0.0")
                    FormRowView(firstItem: "Copyright", secondItem: "@ 2023 Studio757")
                    
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        HStack {
                            Text("Terms")
                            Spacer()
                            Image(systemName: "info.circle")
                        }
                    }
                    
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "info.circle")
                        }
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
