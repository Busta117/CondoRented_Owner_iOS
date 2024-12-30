//
//  OnLoadModifier.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//


import SwiftUI

extension View {
    func onLoad(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnLoadModifier(action: action))
    }
}

struct OnLoadModifier: ViewModifier {
    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    action()
                }
            }
    }
}
