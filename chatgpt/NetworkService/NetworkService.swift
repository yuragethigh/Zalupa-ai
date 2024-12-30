//
//  NetworkService.swift
//  chatgpt
//
//  Created by Yuriy on 29.12.2024.
//

import Combine

protocol NetworkService {
    func request<T: Decodable>(decodedType: T.Type, endPoint: Enpoints) -> AnyPublisher <T, HTTPErrorTypes>
}

