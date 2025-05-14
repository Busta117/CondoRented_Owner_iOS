//
//  NavigatorBar.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import SwiftUI

struct NavigatorBar: View {
    
    var title: String
    var subtitle: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
            if !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .padding(.top, 2)
            }
        }
        .lineLimit(1)
        .truncationMode(.tail)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 44)
//        .background(Color.black)
//        .foregroundColor( Color(.dynamic.content1))
    }
}

// MARK: - Back Button

extension View {
    public func navigatorBackButton(title: String, action: (() -> Void)? = nil) -> some View {
        self.modifier(NavigatorBackButtonModifier(title: title, action: action))
    }
}

private struct NavigatorBackButtonModifier: ViewModifier {
    let title: String
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .padding(.horizontal, 80)
            
            HStack(alignment: .center) {
                CustomBackButton(title: title, action: action)
                Spacer()
            }
            .padding(.horizontal, 8)
            
        }
        .frame(height: 44)
    }
}

private struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var title: String
    let action: (() -> Void)?
    
    var body: some View {
        Button(action: {
            if let action = action {
                action()
            } else {
                self.presentationMode.wrappedValue.dismiss()
            }   
        }) {
            HStack(spacing: 0) {
                Image(systemName: "chevron.left")
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .padding(.top, 0.5)
            }
        }
//        .foregroundColor(Color(UIColor.dynamic.content1))
        .frame(height: 40)
        .padding(.top, 2.5)
        .padding(.leading, -1.5)
    }
}

// MARK: - Navigation Items

extension View {
    public func navigatorBarItems<V, T>(@ViewBuilder leading: @escaping () -> V,
                                        @ViewBuilder trailing: @escaping () -> T) -> some View where V: View, T: View {
        self.modifier(NavigatorBarItems(leading: leading, trailing: trailing))
    }
    
    public func navigatorBarItems<V>(@ViewBuilder leading: @escaping () -> V) -> some View where V: View {
        navigatorBarItems(leading: leading, trailing: { EmptyView() })
    }
    
    public func navigatorBarItems<V>(@ViewBuilder trailing: @escaping () -> V) -> some View where V: View {
        navigatorBarItems(leading: { EmptyView() }, trailing: trailing)
    }
}

private struct NavigatorBarItems<V, T>: ViewModifier where V: View, T: View {
    
    var leading: () -> V
    var trailing: () -> T
    
    init(@ViewBuilder leading: @escaping () -> V,
         @ViewBuilder trailing: @escaping () -> T) {
        self.leading = leading
        self.trailing = trailing
    }
    
    func body(content: Content) -> some View {
        ZStack {
            
            content
            
            HStack {
                leading()
                Spacer()
            }
            HStack {
                Spacer()
                trailing()
            }
        }
//        .background(Color(.dynamic.background1))
        .frame(height: 44)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, apply: (Self) -> Content) -> some View {
        if condition {
            apply(self)
        } else {
            self
        }
    }
}
