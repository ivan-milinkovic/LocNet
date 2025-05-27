//
//  HttpClient.swift
//  LocNetMobile
//
//  Created by Ivan Milinkovic on 26. 5. 2025..
//

import Foundation

class HttpClient {
    
    let urlSession: URLSession
    let baseUrl: URL?
    var requestInterceptor: ((inout URLRequest) -> Void)?
    var responseInterceptor: ((HTTPURLResponse) -> Void)?
    
    init(urlSession: URLSession,
         baseUrl: URL? = nil,
         requestInterceptor: ((inout URLRequest) -> Void)? = nil,
         responseInterceptor: ((HTTPURLResponse) -> Void)? = nil) {
        self.urlSession = urlSession
        self.baseUrl = baseUrl
        self.requestInterceptor = requestInterceptor
        self.responseInterceptor = responseInterceptor
    }
    
    func load(urlRequest: inout URLRequest) async throws(NetworkError) -> Data {
        do {
            requestInterceptor?(&urlRequest)
            let (data, urlResponse) = try await urlSession.data(for: urlRequest)
            let httpResponse = urlResponse as! HTTPURLResponse
            responseInterceptor?(httpResponse)
            switch httpResponse.statusCode {
            case 200...299: return data
            case 401: throw NetworkError.unauthorized
            default: throw NetworkError.unspecified(nil)
            }
        } catch {
            throw NetworkError.unspecified(error)
        }
    }
    
    func makeUrl(withPath path: String) -> URL {
        let url = if let baseUrl {
            baseUrl.appending(path: path)
        } else {
            URL(string: path)!
        }
        return url
    }
    
    func applyJsonHeaders(request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    
    func getJson<TResult: Decodable>(_ path: String) async throws(NetworkError) -> TResult {
        let url = makeUrl(withPath: path)
        var urlRequest = URLRequest(url: url)
        applyJsonHeaders(request: &urlRequest)
        
        let data = try await load(urlRequest: &urlRequest)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(TResult.self, from: data)
            return result
        } catch {
            throw NetworkError.json(error)
        }
    }
    
    func sendJson<TBody: Encodable, TResult: Decodable>
    (url: URL, httpMethod: String, body: TBody?)
    async throws(NetworkError) -> TResult
    {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        applyJsonHeaders(request: &urlRequest)
        
        do {
            let jsonEncoder = JSONEncoder()
            let bodyData = try jsonEncoder.encode(body)
            urlRequest.httpBody = bodyData
        } catch {
            throw NetworkError.json(error)
        }
        
        let data = try await load(urlRequest: &urlRequest)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let result = try decoder.decode(TResult.self, from: data)
            return result
        } catch {
            throw NetworkError.json(error)
        }
        
    }
    
    func sendJson<TBody: Encodable>
    (url: URL, httpMethod: String, body: TBody?)
    async throws(NetworkError) -> Void
    {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        
        do {
            let jsonEncoder = JSONEncoder()
            let bodyData = try jsonEncoder.encode(body)
            urlRequest.httpBody = bodyData
        } catch {
            throw NetworkError.json(error)
        }
        
        let _ = try await load(urlRequest: &urlRequest)
    }
    
    func postJson<TBody: Encodable, TResult: Decodable>(path: String, body: TBody) async throws(NetworkError) -> TResult {
        let url = makeUrl(withPath: path)
        return try await sendJson(url: url, httpMethod: "post", body: body)
    }
    
    func postJson<TBody: Encodable>(path: String, body: TBody) async throws(NetworkError) -> Void {
        let url = makeUrl(withPath: path)
        try await sendJson(url: url, httpMethod: "post", body: body)
    }
    
    
    func putJson<TBody: Encodable, TResult: Decodable>(path: String, body: TBody) async throws(NetworkError) -> TResult {
        let url = makeUrl(withPath: path)
        return try await sendJson(url: url, httpMethod: "put", body: body)
    }
    
    func putJson<TBody: Encodable>(path: String, body: TBody) async throws(NetworkError) -> Void {
        let url = makeUrl(withPath: path)
        try await sendJson(url: url, httpMethod: "put", body: body)
    }
    
    
    func delete<TBody: Encodable, TResult: Decodable>(path: String, body: TBody) async throws(NetworkError) -> TResult {
        let url = makeUrl(withPath: path)
        return try await sendJson(url: url, httpMethod: "delete", body: body)
    }
    
    func delete<TBody: Encodable>(path: String, body: TBody) async throws(NetworkError) -> Void {
        let url = makeUrl(withPath: path)
        try await sendJson(url: url, httpMethod: "delete", body: body)
    }
}
