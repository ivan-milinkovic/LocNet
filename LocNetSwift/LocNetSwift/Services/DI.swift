import Foundation

@MainActor
class DI {
    let router: Router
    let session: Session
    let httpClient: HttpClient
    let apiService: ApiService
    
    init() {
        httpClient = HttpClient(session: URLSession.shared)
        session = Session(modifyingHttpClient: httpClient)
        
        router = Router()
        router.observe(session: session)
        
        apiService = ApiService(apiUrl: Constants.apiUrl, httpClient: httpClient)
    }
}
