//
//  Misc.swift
//  CityGuide
//
//  Created by Tomas Cejka on 23.04.2025.
//

enum HttpMethod: String {
    case get = "GET"
}



enum APIError: Error {
    case invalidHost
    case invalidURLComponents
    case noResponse
    case unacceptableResponseStatusCode
    case customDecodingFailed
}
