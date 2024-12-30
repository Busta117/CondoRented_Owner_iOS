//
//  NavigatorView.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import Combine
import SwiftUI


struct CustomNavigationBar: View {
    let title: String
    let scrollOffset: CGFloat
    let leadingAction: (() -> Void)?
    let trailingAction: (() -> Void)?

    var body: some View {
        ZStack {
            if scrollOffset > -150 {
                Color.white
                    .frame(height: 44)
            }

            HStack {
                if scrollOffset < -150 {
                    Text(title)
                        .font(.title3)
                        .bold()
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text(title)
                        .font(.largeTitle)
                        .bold()
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                if let leadingAction = leadingAction {
                    Button(action: leadingAction) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }

                if let trailingAction = trailingAction {
                    Button(action: trailingAction) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal)
        }
        .zIndex(1) // Mantener la barra encima del contenido
    }
}

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }

    static func reduce(value: inout CGFloat, nextValue: CGFloat) {
        value = nextValue
    }
}

struct ScrollableContentView<Content: View>: View {
    @Binding var scrollOffset: CGFloat
    let content: Content

    init(scrollOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._scrollOffset = scrollOffset
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if scrollOffset < -100 {
                    Color.white
                        .frame(height: 44) // Espaciador solo si necesario
                }

                content
            }
        }
//        .background(
//            GeometryReader { geo in
//                Color.clear
//                    .onAppear {
//                        self.scrollOffset = geo.frame(in: .global).minY
//                    }
//                    .onGeometryChange(for: ScrollOffsetKey.self) { value in
//                        self.scrollOffset = value
//                    }
//            }
//        )
        .zIndex(0) // Mantener el contenido detrás de la barra
    }
}


extension View {
    func customTitle(_ title: String) -> some View {
        self.modifier(NavigationTitleModifier(title: title))
    }
}

//extension View {
//    func toUIViewController() -> UIViewController? {
//        let controller = UIHostingController(rootView: self)
//        return controller
//    }
//}

//extension View {
//    func navigationController() -> UINavigationController? {
//            var currentViewController: UIViewController? = UIHostingController(rootView: self).rootViewController
//            
//            while let viewController = currentViewController {
//                if let navController = viewController as? UINavigationController {
//                    return navController
//                }
//                currentViewController = viewController.parent
//            }
//            
//            return nil
//        }
//}


struct NavigationTitleModifier: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        content
//            .onAppear {
//                if let navController = content.navigationController() {
//                    navController.topViewController?.title = title
//                } else {
//                    print("No UINavigationController found.")
//                }
//            }
    }
    
}


struct NavigatorView<Route: RouteProtocol, Screen: View>: UIViewControllerRepresentable {
    let router: NavigatorRouter<Route>
    @ViewBuilder let builder: (Route) -> Screen
    
    @State private var navigationTitle: String = "" // Track the title state
    
    class Coordinator {
        var parent: NavigatorView
        var navigation: UINavigationController?
        
        init(parent: NavigatorView) {
            self.parent = parent
        }
        
        func updateNavigationTitle() {
            guard let navigation = navigation else { return }
            navigation.topViewController?.title = self.parent.navigationTitle
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigation = UINavigationController()
//        navigation.navigationBar.prefersLargeTitles = true
        navigation.navigationBar.isHidden = true
        context.coordinator.navigation = navigation
        
        for route in router.routes {
            let view = builder(route)
            let host = UIHostingController(rootView: view)
            navigation.pushViewController(host, animated: false)
        }
        
        router.onPush = { route in
            let view = builder(route)
            let host = UIHostingController(rootView: view)
            context.coordinator.navigation?.pushViewController(host, animated: true)
        }

        router.onPop = {
            context.coordinator.navigation?.popViewController(animated: true)
        }

        router.onPopToRoot = {
            context.coordinator.navigation?.popToRootViewController(animated: true)
        }
        
        context.coordinator.updateNavigationTitle()
        
        return navigation
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        context.coordinator.updateNavigationTitle()
    }
}
