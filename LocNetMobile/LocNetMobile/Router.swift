//
//  Router.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation
import Observation


@Observable
class Router {
    var route: LandingRoute = .login
}

enum LandingRoute: Equatable {
    case login
    case main(MainRoute)
    
    var isLogin: Bool {
        if case .login = self { return true }
        else {return false}
    }
}

enum MainRoute: Equatable {
    case projects(String?)
}
