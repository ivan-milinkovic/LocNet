import Foundation

@MainActor
class Session {
    
    var tokens: Tokens? = nil
    @Published var state: SessionState = .undetermined
    let httpClient: HttpClient
    
    init(modifyingHttpClient httpClient: HttpClient) {
        self.httpClient = httpClient
        httpClient.requestDecorator = makeAuthorizeRequestDecorator()
        httpClient.unauthorizedDetected = { [weak self] in
            self?.unauthorizedDetected()
        }
    }
    
    func makeAuthorizeRequestDecorator() -> ((inout URLRequest) -> Void) {
        { [self] request in
            if let accessToken = tokens?.accessToken {
                request.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            }
        }
    }
    
    // todo: use keychain, handle errors
    
    let tokensStoreKey = "auth_tokens"
    
    func storeAuthTokens() {
        guard let tokens else { return }
        let data = try? JSONEncoder().encode(tokens)
        UserDefaults.standard.set(data, forKey: tokensStoreKey)
    }
    
    func loadStoredAuthTokens() {
        guard let data = UserDefaults.standard.data(forKey: tokensStoreKey),
              let storedTokens = try? JSONDecoder().decode(Tokens.self, from: data),
              Date.now < storedTokens.expiresAt
        else {
            state = .loggedOut
            return
        }
        
        tokens = storedTokens
        state = .loggedIn
    }
    
    func removeStoredAuthTokens() {
        UserDefaults.standard.removeObject(forKey: tokensStoreKey)
    }
    
    func login(_ credentials: LoginCredentials) async {
        let loginUrl = Constants.apiUrl.appending(component: "login")
        do {
            let result: Tokens = try await httpClient.post(url: loginUrl, model: credentials)
            tokens = result
            state = .loggedIn
            storeAuthTokens()
        } catch {
            state = .loggedOut
        }
    }
    
    func logout() async {
        tokens = nil
        state = .loggedOut
        removeStoredAuthTokens()
    }
    
    func unauthorizedDetected() {
        // don't call logout, because it might, depending on the auth setup, call the backend to logout
        tokens = nil
        removeStoredAuthTokens()
        state = .loggedOut
    }
}

enum SessionState {
    case undetermined
    case loggedOut
    case loggedIn
}

struct LoginCredentials: Encodable {
    let email: String
    let password: String
}

struct Tokens: Codable {
    let accessToken: String
    let refreshToken: String?
    let tokenType: String?
    let expiresAt: Date
    private let expiresIn: Int // the original expiry seconds received from the API, hide it as it is misleading, because time goes on
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accessToken = try container.decode(String.self, forKey: .accessToken)
        self.refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
        self.tokenType = try container.decodeIfPresent(String.self, forKey: .tokenType)
        expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        expiresAt = Date.now.addingTimeInterval(Double(expiresIn))
    }
}
