import Foundation
import Observation
import Combine

@MainActor
@Observable
class Router {
    
    var route: Route = .launch
    var subs: Set<AnyCancellable> = []
    
    func observe(session: Session) {
        session.$state.sink { [weak self] sessionState in
            self?.route = switch sessionState {
            case .undetermined: .launch
            case .loggedOut: .login
            case .loggedIn: .main
            }
        }
        .store(in: &subs)
    }
}

enum Route {
    case launch
    case login
    case main
}
