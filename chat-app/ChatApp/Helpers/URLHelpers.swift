//
//  URLHelpers.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

extension URL {
    func addQueryItems(_ queryItems: [String: Any?]) -> URL? {
        let urlString = absoluteString
        let concatenateChar = urlString.contains("?") ? "&" : "?"
        let addPrecentEncoding: (String) -> String? = {
            guard let value = $0.removingPercentEncoding,
                  let encodedValue = value.addingPercentEncoding()
            else { return nil }
            return encodedValue
        }
        let flatStringArray: (String, [String]) -> String? = { key, arrayValue in
            let stringValue = arrayValue
                .compactMap {
                    guard let encodedValue = addPrecentEncoding($0) else { return nil }
                    return "\(key)[]=\(encodedValue)"
                }
                .joined(separator: "&")
            return stringValue.isEmpty ? nil : stringValue
        }
        let queryString: String = queryItems
            .compactMap {
                let key = $0.key
                if let stringValue = $0.value as? String {
                    guard let encodedValue = addPrecentEncoding(stringValue) else { return nil }
                    return "\(key)=\(encodedValue)"
                } else if let arrayValue = $0.value as? [String] {
                    return flatStringArray(key, arrayValue)
                } else {
                    return nil
                }
            }
            .joined(separator: "&")
        guard !queryString.isEmpty else { return self }
        let urlFullString = "\(urlString)\(concatenateChar)\(queryString)"
        return URL(string: urlFullString)
    }
}
