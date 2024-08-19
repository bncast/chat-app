//
//  RespondableApiEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

protocol RespondableApiEntity: RespondableEntity {
    var success: Int { get }
    var error: ErrorMessage? { get }
}

