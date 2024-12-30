//
//  NavigatorRouter.swift
//  CondoRented_Owner
//
//  Created by Santiago Bustamante on 20/12/24.
//

import Foundation
import Combine

protocol RouteProtocol: Equatable {}

final class NavigatorRouter<Route: RouteProtocol>: ObservableObject {

    // MARK: - Properties

    internal var routes = [Route]()
    internal var onPush: ((Route) -> Void)?
    internal var onPop: (() -> Void)?
    internal var onPopToRoot: (() -> Void)?
    internal var current: Route? {
        routes.last
    }

    // MARK: - Initializer

    public init(initial: Route? = nil) {
        if let initial = initial {
            routes.append(initial)
        }
    }

    // MARK: - Public Functions

    public func push(_ route: Route) {
        routes.append(route)

        // notify listener
        onPush?(route)
    }

    public func pop() {
        if !routes.isEmpty {
            routes.removeLast()
        }

        // notify listener
        onPop?()
    }

    public func popToRoot() {
        routes.removeAll()
        
        // notify listener
        onPopToRoot?()
    }
}
