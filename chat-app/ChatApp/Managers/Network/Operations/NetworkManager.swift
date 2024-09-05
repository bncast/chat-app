//
//  NetworkManager.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

final class NetworkManager {
    private var queue = OperationQueue()
    private var queueForBackground: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Network Manager Queue for background"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    static var shared = NetworkManager()
    func register(operation: Operation) {
        if (operation as? BaseNetworkOperation)?.backgroundTaskIdentifier != nil {
            queueForBackground.addOperation(operation)
        } else {
            queue.addOperation(operation)
        }
    }
}
