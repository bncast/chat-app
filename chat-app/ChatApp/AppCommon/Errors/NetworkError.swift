//
//  NetworkError.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

enum NetworkError: Error, CustomDebugStringConvertible, Equatable, LocalizedError, Codable {
    var debugDescription: String {
        "Network error -> Code:\(code) Message:\(message)"
    }

    static func == (lValue: NetworkError, rValue: NetworkError) -> Bool {
        lValue.code == rValue.code
    }

    case cancelled
    case timeout
    case offline
    case invalidResponse
    case systemError(Error)
    case custom(String, String)
    case appServerError(ErrorEntity)

    private enum CodingKeys: String, CodingKey {
        case type
        case code
        case message
        case errorEntity
    }

    init?(_ error: Error?) {
        guard let error else { return nil }

        if let temp = error as? NetworkError { self = temp; return }

        switch error._code {
        case NSURLErrorNotConnectedToInternet,
            NSURLErrorDataNotAllowed,
        NSURLErrorNetworkConnectionLost:
            self = .offline; return
        case NSURLErrorTimedOut:
            self = .timeout; return
        default:
            self = .systemError(error); return
        }
    }

    init(appServerResponse responseBody: Data?) {
        guard let data = responseBody else { self = .invalidResponse; return }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let errorInfo = try? decoder.decode(ErrorEntity.self, from: data)
        else { self = .invalidResponse; return }
        self = .appServerError(errorInfo)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        let code = try values.decode(String.self, forKey: .code)
        let message = try values.decode(String.self, forKey: .message)
        switch type {
        case NetworkError.timeout.type: self = .timeout
        case NetworkError.offline.type: self = .offline
        case NetworkError.cancelled.type: self = .cancelled
        default:
            self = .custom(code, message)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        switch self {
        case .systemError, .custom:
            try container.encode(code, forKey: .code)
            try container.encode(message, forKey: .message)
        default: break
        }
    }

    var type: String {
        switch self {
        case .timeout: "timeout"
        case .offline: "offline"
        case .cancelled: "canceled"
        case .systemError: "systemError"
        case .custom: "custom"
        case .invalidResponse: "invalidResponse"
        case .appServerError: "appServerError"
        }
    }

    var code: String {
        switch self {
        case .timeout:
            String(NSURLErrorTimedOut)
        case .offline:
            String(NSURLErrorNotConnectedToInternet)
        case .systemError(let error):
            "\(error._code)"
        case .cancelled:
            "0"
        case .custom(let code, _):
            "Custom Error:\(code)"
        case .invalidResponse:
            "invalid_response"
        case .appServerError(let errorInfo):
            errorInfo.error?.code ?? ""
        }
    }

    var title: String? { "" }

    var message: String {
        switch self {
        case .systemError(let error):
            error.localizedDescription
        case .cancelled:
            "Network operation canceled."
        case .timeout:
            "networkErrorTimeout"
        case .offline:
            "networkErrorOffline"
        case .custom(_, let message):
            message
        case .appServerError(let errorInfo):
            errorInfo.error?.message ?? ""
        case .invalidResponse:
            "networkErrorInvalidResponse"
        }
        
    }
}
