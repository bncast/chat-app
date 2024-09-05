//
//  RequestableEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

protocol RequestBody: Codable {
    var contentType: String { get }
    var encoder: JSONEncoder { get }
    func encode() -> Data?
}

extension RequestBody {
    static func getRequestTime() -> String {
        "\(Date())"
    }
}

protocol RequestJsonBody: RequestBody {}

extension RequestJsonBody {
    var contentType: String { "application/json; charset=utf-8" }

    func encode() -> Data? {
        do {
            return try encoder.encode(self)
        } catch {
            fatalError("We couldn't encode request body.")
        }
    }
}

protocol RequestUrlEncodedBody: RequestBody {}

extension RequestUrlEncodedBody {
    var contentType: String { "application/x-www-form-urlencoded; charset=utf-8" }

    func encode() -> Data? {
        do {
            guard let dict = (try JSONSerialization.jsonObject(with: encoder.encode(self))) as? [String: Any]
            else { return nil }
            let bodyString: String = dict.compactMap { getEncodedKeyValueString(key: $0, value: $1) }
                .joined(separator: "&")
            return bodyString.data(using: .utf8)
        } catch {
            fatalError("Failed to encode body. Error:\(error)")
        }
    }

    private func getEncodedKeyValueString(key: String, value: Any) -> String? {
        if let stringValue = value as? String, let encodedValue = stringValue.addingPercentEncoding() {
            "\(key.addingPercentEncoding() ?? "")=\(encodedValue)"
        } else if let intValue = value as? Int {
            "\(key.addingPercentEncoding() ?? "")=\(intValue)"
        } else if let arrayValue = value as? [Any] {
            arrayValue.enumerated().compactMap {
                getEncodedKeyValueString(key: "\(key)[\($0.offset)]", value: $0.element)
            }.joined(separator: "&")
        } else if let dictValue = value as? [String: Any] {
            dictValue.compactMap { getEncodedKeyValueString(key: "\(key)[\($0)]", value: $1) }
                .joined(separator: "&")
        } else {
            nil
        }
    }
}

protocol RequestableEntity {
    associatedtype ResponseEntity: RespondableEntity

    static var method: BaseNetworkOperation.Method { get }

    var requestURL: URL { get }
    var timeout: TimeInterval? { get }
    var queryParams: [String: Any?]? { get }
    var body: RequestBody? { get }
    var isIgnoreAccessTokenError: Bool { get }
    var isIgnoreLogoutErrors: Bool { get }

    func didStartTask()
    func processForCompletion(response: ResponseEntity?, error: Error?) -> Error?
}

extension RequestableEntity {
    var apiName: String { "\(Self.self)" }
    var timeout: TimeInterval? { nil }
    var queryParams: [String: Any?]? { nil }
    var body: RequestBody? { nil }
    var completionHandler: (() -> Void)? { nil }
    var isIgnoreAccessTokenError: Bool { false }
    var isIgnoreLogoutErrors: Bool { false }

    func didStartTask() {}
    func processForCompletion(response: ResponseEntity?, error: Error?) -> Error? { nil }

    @discardableResult
    func run(priority: Operation.QueuePriority = .normal) async throws -> ResponseEntity {
        try await AppServerOperation(request: self).run(priority: priority)
    }
}

