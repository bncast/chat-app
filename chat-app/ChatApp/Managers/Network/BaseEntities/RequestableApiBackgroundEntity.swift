//
//  RequestableApiBackgroundEntity.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

protocol RequestableApiBackgroundEntity: RequestableApiEntity {
    var needToRunInBackground: Bool { get }
}

extension RequestableApiBackgroundEntity {
    var needToRunInBackground: Bool { true }

    func getBackgroundTaskIdentifier() -> String {
        UUID().uuidString
    }
}
