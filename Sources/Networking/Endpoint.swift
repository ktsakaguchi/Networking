//
//  Endpoint.swift
//  ShowTracker
//
//  Created by Kei Sakaguchi on 9/12/24.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case patch = "PATCH"
    case options = "OPTIONS"
    case connect = "CONNECT"
    case trace = "TRACE"
}

public typealias HTTPHeaders = [String: String]
public typealias HTTPParams = [String: String]
public typealias HTTPBody = [String: Any]

public protocol Endpoint {
    var httpMethod: HTTPMethod { get }
    
    var baseURL: String { get }
    
    var path: String { get }

    var headers: HTTPHeaders { get }

    var parameters: HTTPParams? { get }

    var body: HTTPBody? { get }

    var decoder: JSONDecoder { get }
    
    func asURLRequest() -> URLRequest?
}

extension Endpoint {
    public var parameters: HTTPParams? {
        return nil
    }
    
    public var body: HTTPBody? {
        return nil
    }

    public var decoder: JSONDecoder {
        return JSONDecoder()
    }
    
    public func asURLRequest() -> URLRequest? {
        guard let url = buildURLComponents()?.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
}

extension Endpoint {
    private func buildURLComponents() -> URLComponents? {
        var components = URLComponents(string: baseURL)
        components?.path = path
        components?.queryItems = parameters?.compactMap { key, value in
            URLQueryItem(name: key, value: value)
        }
        return components
    }
}
