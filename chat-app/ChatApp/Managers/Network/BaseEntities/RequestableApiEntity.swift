//
//  RequestableApiEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

protocol RequestableApiEntity: RequestableEntity {
    var scheme: String? { get }
    var host: String? { get }
    var path: String { get }
}

extension RequestableApiEntity {
    var scheme: String? { nil }
    var host: String? { nil }

    var requestURL: URL {
        let scheme = scheme ?? AppConstant.shared.appServerScheme
        let host = host ?? AppConstant.shared.appServerHost

        let baseUrl = "\(scheme)://\(host)"
        guard let url = URL(string: "\(baseUrl)/api/\(path)") else {
            fatalError("Failed to make url=> \(self)")
        }
        if let queryParams = queryParams,
           let url = url.addQueryItems(queryParams) {
            return url
        }
        return url
    }
}
