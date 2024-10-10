//
//  NetworkManager.swift
//  ShowTracker
//
//  Created by Kei Sakaguchi on 9/12/24.
//

import Foundation

public enum NetworkError: Error {
    case invalidURL
}

public protocol Cancellable {
    func cancel()
    
    var isCancelled: Bool { get }
}

extension URLSessionTask: Cancellable {
    public var isCancelled: Bool {
        state == .canceling
    }
}

public class NetworkManager {
    private let urlSession = URLSession.shared

    public init() {}
    
    @available(macOS 10.15, *)
    @available(iOS 13.0, *)
    public func sendRequest<T: Decodable>(endpoint: Endpoint) async -> Result<T, Error> {
        await withUnsafeContinuation { continuation in
            let _ = sendRequest(endpoint: endpoint) { result in
                continuation.resume(returning: result)
            }
        }
    }

    public func sendRequest<T: Decodable>(endpoint: Endpoint,
                                          completion: ((Result<T, Error>) -> Void)?) -> Cancellable? {
        guard let urlRequest = endpoint.asURLRequest() else {
            completion?(.failure(NetworkError.invalidURL))
            return nil
        }
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion?(.failure(error))
            } else if let data = data {
                do {
                    let decodedModel = try endpoint.decoder.decode(T.self, from: data)
                    completion?(.success(decodedModel))
                } catch {
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
        return task
    }
}
