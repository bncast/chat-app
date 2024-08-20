//
//  AppServerOperation.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import Foundation

private var semaphoreForRefreshToken = DispatchSemaphore(value: 1)

class AppServerOperation<Req: RequestableEntity, Res: RespondableEntity>: BaseNetworkOperation, NSCopying {
    func copy(with _: NSZone? = nil) -> Any {
        let operation = AppServerOperation(request: requestEntity)
        operation.continuation = continuation
        return operation
    }

    override var url: URL { requestEntity.requestURL }

    override var timeout: TimeInterval { requestEntity.timeout ?? 60 }

    override var method: Method { Req.method }

    override var header: [String: String]? {
        guard requestEntity is (any RequestableApiEntity) else { return nil }
        let timestamp = "\(Date())"
        let deviceId = AppConstant.shared.deviceId ?? ""

        let header = [
            "Cache-Control": "no-cache",
            "X-CHATAPP-Timestamp": timestamp,
            "X-CHATAPP-Key": deviceId,
            "X-CHATAPP-Signature": "chatapp\(deviceId)\(timestamp)",
            "Content-Type": "application/json; charset=utf-8"
        ]

        return header
    }

    override var backgroundTaskIdentifier: String? {
        (requestEntity as? (any RequestableApiBackgroundEntity))?.getBackgroundTaskIdentifier()
    }

    private var requestEntity: Req

    init(request: Req) {
        requestEntity = request
        super.init()
    }

    override var requestBody: Data? {
        requestEntity.body?.encode()
    }

    override func didStartTask() {
        requestEntity.didStartTask()
    }

    override final func checkResponse(_ response: HTTPURLResponse, responseBody: Data?) throws -> Any {
        switch response.statusCode {
        case 200 ..< 300:
            if let data = responseBody,
               let parsedBody = try parseBody(response, responseBody: data) {
                return parsedBody
            }
            fallthrough
        default:
            throw NetworkError(appServerResponse: responseBody)
        }
    }

    final func parseBody(_ response: HTTPURLResponse, responseBody: Data) throws -> Any? {
        let result: Res?
        if responseBody.isEmpty {
            let dummyData = "{}".data(using: .utf8).unsafelyUnwrapped
            result = try Res.decode(target: dummyData)
        } else {
            result = try Res.decode(target: responseBody)
            if result is RespondableApiEntity {
                guard (result as? RespondableApiEntity)?.success == 1 else {
                    throw NetworkError(appServerResponse: responseBody)
                }
            }
        }
        processForResponseHeader(response.allHeaderFields, isSucceedToParse: result != nil)
#if DEBUG
        if result == nil {
            print("Response parsed:\n\(responseBody.prettyPrintedJSON ?? "")")
        }
#endif
        return result
    }

    func processForResponseHeader(_: [AnyHashable: Any], isSucceedToParse _: Bool) {}
    func parseRedirectItem(fromResponseHeader _: [AnyHashable: Any]) -> String? { nil }

    override final func completedOperation(with body: Any?, error: NetworkError?) {
        guard let continuation else { fatalError("There is no continuation.") }
        if let error {
            let newError = requestEntity.processForCompletion(response: nil, error: error)
            continuation.resume(throwing: newError ?? error)
            return
        }
        guard let response = body as? Res else {
            let newError = requestEntity.processForCompletion(response: nil, error: NetworkError.invalidResponse)
            continuation.resume(throwing: newError ?? NetworkError.invalidResponse)
            return
        }
        if let error = requestEntity.processForCompletion(response: response as? Req.ResponseEntity, error: nil) {
            continuation.resume(throwing: error)
        } else {
            continuation.resume(returning: response)
        }
    }

    var continuation: CheckedContinuation<Res, Error>?

    @discardableResult
    func run(priority: Operation.QueuePriority = .normal, isUpdateToken: Bool = false) async throws -> Res {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            self.priority = priority
            NetworkManager.shared.register(operation: self)
        }
    }
}
