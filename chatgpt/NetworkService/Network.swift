//
//  Network.swift
//  chatgpt
//
//  Created by Yuriy on 26.12.2024.
//

import Foundation
import Combine

protocol NetworkService {
    func request<T: Decodable>(decodedType: T.Type, endPoint: Enpoints) -> AnyPublisher <T, HTTPErrorTypes>
}


final class Network: NetworkService {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let url: String
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        url: String = URLs.main
    ) {
        self.session = session
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
        self.url = url
    }
    
    
    func request<T: Decodable>(decodedType: T.Type, endPoint: Enpoints) -> AnyPublisher <T, HTTPErrorTypes> {
        
        guard let url = URL(string: url + endPoint.rawValue) else {
            return Fail(error: HTTPErrorTypes.invalidURL).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .tryMap { data, response -> Data in
                guard let response = response as? HTTPURLResponse else {
                    throw HTTPErrorTypes.failableCastResponse
                }
                
                let statusCode = response.statusCode
                
                guard statusCode == 200 else {
                    let stringError = String(data: data, encoding: .utf8)
                    throw HTTPErrorTypes.invalidStatusCode(statusCode, stringError ?? "")
                }
                
                return data
            }
            .decode(type: decodedType.self, decoder: decoder)
            .mapError { error in
                error as? HTTPErrorTypes ?? HTTPErrorTypes.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
}
