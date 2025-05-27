//
//  APIManager.swift
//  CityGuide
//
//  Created by Tomas Cejka on 23.04.2025.
//

import Foundation

protocol APIManaging {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

class APIManager: APIManaging {

    let decoder = JSONDecoder()

    func request<T>(_ endpoint: any Endpoint) async throws -> T where T : Decodable {

        let request: URLRequest = try endpoint.asRequest()

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.noResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.unacceptableResponseStatusCode
        }

        let object = try decoder.decode(T.self, from: data)

        return object
    }


}
