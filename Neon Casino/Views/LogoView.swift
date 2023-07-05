//
//  LogoView.swift
//  Slot Machine
//
//  Created by Kelvin Reid on 7/1/23.
//

import SwiftUI

struct LogoView: View {
    var logoFileName: String
    
    var body: some View {
        Image(logoFileName)
            .resizable()
            .scaledToFit()
            .frame(minWidth: 256, idealWidth: 300, maxWidth: 320, minHeight: 112, idealHeight: 130, maxHeight: 140, alignment: .center)
//            .padding(.horizontal)
//            .layoutPriority(1)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView(logoFileName: "slots-background")
    }
}
