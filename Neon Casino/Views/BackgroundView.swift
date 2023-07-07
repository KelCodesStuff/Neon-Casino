//
//  BackgroundView.swift
//  Neon Casino
//
//  Created by Kelvin Reid on 7/6/23.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        Image("slots-background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
