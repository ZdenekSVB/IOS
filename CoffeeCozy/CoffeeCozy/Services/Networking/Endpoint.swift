//
//  Endpoint.swift
//  CityGuide
//
//  Created by Tomas Cejka on 23.04.2025.
//

import Foundation

//let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=48.48&daily=temperature_2m_max")

protocol Endpoint {
    var host: String { get } // https://api.open-meteo.com
    var path: String { get } // v1/forecast
    var method: HttpMethod { get } // GET
    var urlParameters: [String: Any]? { get }
    var headers: [String: String] { get }

    func asRequest() throws -> URLRequest
}

extension Endpoint {
    var host: String {
        "https://api.open-meteo.com"
    }

    var method: HttpMethod {
        .get
    }

    var headers: [String: String] {
        [:]
    }

    var urlParameters: [String: Any]? {
        nil
    }


    func asRequest() throws -> URLRequest {
        guard let host = URL(string: host) else {
            throw APIError.invalidHost
        }

        let urlPath = host.appendingPathComponent(path)

        guard var urlComponents = URLComponents(url: urlPath, resolvingAgainstBaseURL: true) else {
            throw APIError.invalidURLComponents
        }


        if let urlParameters {
            urlComponents.queryItems = urlParameters.map {
                URLQueryItem(name: $0.key, value: String(describing: $0.value))
            }
        }

        guard let url = urlComponents.url else {
            throw APIError.invalidURLComponents
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        request.setValue("application/json", forHTTPHeaderField: "Content-type")

        print(url)
        return request
    }
}
