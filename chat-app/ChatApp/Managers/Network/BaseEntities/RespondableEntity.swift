//
//  RespondableEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

protocol RespondableEntity: Codable {
    static var decoder: JSONDecoder { get }
}

extension RespondableEntity {
    static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    static func decode(target: Data) throws -> Self? {
        do {
            return try Self.decoder.decode(Self.self, from: target)
        } catch {
            switch error {
            case DecodingError.typeMismatch(let type, let context):
                print("Type is mismatched.\nObject:\(self)\nError:type:\(type) content:\(context)")
            case DecodingError.dataCorrupted(let context):
                print("Data is currupted.\nObject:\(self)\nError:content:\(context)")
            case DecodingError.keyNotFound(let key, let context):
                print("Could not find key.\nObject:\(self)\nError:key:\(key) content:\(context)")
            case DecodingError.valueNotFound(let type, let context):
                print("Could not find value.\nObject:\(self)\nError:type:\(type) content:\(context)")
            default: break
            }
            print("Origin response\n\(target.prettyPrintedJSON ?? "nil")")
            throw NetworkError.systemError(error)
        }
    }
}

