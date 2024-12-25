import Foundation

@MainActor
class HttpClient {
    
    let session: URLSession
    var requestDecorator: ((inout URLRequest) -> Void)?
    var unauthorizedDetected: (() -> Void)?
    
    init(session: URLSession) {
        self.session = session
    }
    
    func load(request: inout URLRequest) async throws(HttpClientError) -> Data {
        do {
            requestDecorator?(&request)
            let (data, response) = try await session.data(for: request)
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            switch statusCode {
            case 200...299: return data
            case 401:
                unauthorizedDetected?()
                throw HttpClientError.unauthorized
            default: throw HttpClientError.unknown(data, httpResponse)
            }
        } catch let e {
            throw HttpClientError.system(e)
        }
    }
    
    func setCommonHeaders(_ request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func get<TResult: Decodable>(url: URL) async throws(HttpClientError) -> TResult {
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        setCommonHeaders(&req)
        
        let data = try await load(request: &req)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let model = try jsonDecoder.decode(TResult.self, from: data)
            return model
        } catch {
            throw HttpClientError.jsonDecoding(error)
        }
    }
    
    func post<TRequest: Encodable, TResult: Decodable>(url: URL, model: TRequest) async throws(HttpClientError) -> TResult {
        return try await sendJson(url: url, model: model, method: "POST")
    }
    
    func post<TRequest: Encodable>(url: URL, model: TRequest) async throws(HttpClientError) -> Void {
        try await sendJson(url: url, model: model, method: "POST")
    }
    
    func put<TRequest: Encodable, TResult: Decodable>(url: URL, model: TRequest) async throws(HttpClientError) -> TResult {
        return try await sendJson(url: url, model: model, method: "PUT")
    }
    
    func put<TRequest: Encodable>(url: URL, model: TRequest) async throws(HttpClientError) -> Void {
        try await sendJson(url: url, model: model, method: "PUT")
    }
    
    func delete<TRequest: Encodable, TResult: Decodable>(url: URL, model: TRequest?) async throws(HttpClientError) -> TResult {
        return try await sendJson(url: url, model: model, method: "DELETE")
    }
    
    func delete<TRequest: Encodable>(url: URL, model: TRequest?) async throws(HttpClientError) -> Void {
        try await sendJson(url: url, model: model, method: "DELETE")
    }
    
    func sendJson<TRequest: Encodable, TResult: Decodable>(url: URL, model: TRequest?, method: String) async throws(HttpClientError) -> TResult {
        var req = URLRequest(url: url)
        req.httpMethod = method
        setCommonHeaders(&req)
        
        do {
            let jsonEncoder = JSONEncoder()
            let requestBody = try jsonEncoder.encode(model)
            req.httpBody = requestBody
        } catch {
            throw HttpClientError.jsonEncoding(error)
        }
            
        let data = try await load(request: &req)
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let model = try jsonDecoder.decode(TResult.self, from: data)
            return model
        } catch {
            throw HttpClientError.jsonDecoding(error)
        }
    }
    
    func sendJson<TRequest: Encodable>(url: URL, model: TRequest?, method: String) async throws(HttpClientError) -> Void {
        var req = URLRequest(url: url)
        req.httpMethod = method
        setCommonHeaders(&req)
        
        do {
            let jsonEncoder = JSONEncoder()
            let requestBody = try jsonEncoder.encode(model)
            req.httpBody = requestBody
        } catch {
            throw HttpClientError.jsonEncoding(error)
        }
        
        let _ = try await load(request: &req)
    }
}

enum HttpClientError: Error {
    case system(Error)
    case unknown(Data?, HTTPURLResponse)
    case unauthorized
    case jsonEncoding(Error)
    case jsonDecoding(Error)
}
