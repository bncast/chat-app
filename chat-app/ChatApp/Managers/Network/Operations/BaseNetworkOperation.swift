//
//  BaseNetworkOperation.swift
//  ChatApp
//
//  Created by Ramon Jr Bahio on 8/19/24.
//

import UIKit

class BaseNetworkOperation: Operation {
    enum Method: CustomStringConvertible {
        case get
        case post
        case put
        case delete
        case patch

        var description: String {
            switch self {
            case .get: "GET"
            case .post: "POST"
            case .put: "PUT"
            case .delete: "DELETE"
            case .patch: "PATCH"
            }
        }
    }

    var timeout: TimeInterval { 60 }
    var method: Method { fatalError("You must override method.") }
    var header: [String: String]? { nil }
    var requestBody: Data? { nil }
    var url: URL { fatalError("You must override url") }
    var successCode: [Int] = [200]
    var isSuccess: Bool {
        guard let httpResponse else { return false }
        return successCode.contains(httpResponse.statusCode)
    }

    var request: URLRequest {
        var request = URLRequest(url: url,
                                 cachePolicy: .useProtocolCachePolicy,
                                 timeoutInterval: timeout)
        request.httpMethod = "\(method)"
        if let header {
            for (key, value) in header {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        request.httpBody = requestBody
        return request
    }

    private var backgroundTaskId: UIBackgroundTaskIdentifier = .invalid
    var isDone = false {
        willSet { willChangeValue(forKey: "isFinished") }
        didSet {
            if isDone {
                guard backgroundTaskId != .invalid else { return }
                UIApplication.shared.endBackgroundTask(backgroundTaskId)
            }
            didChangeValue(forKey: "isFinished")
        }
    }

    var priority: Operation.QueuePriority = .normal {
        willSet { willChangeValue(forKey: "queuePriority") }
        didSet { didChangeValue(forKey: "queuePriority") }
    }

    var isReadyToRun = true {
        willSet { willChangeValue(forKey: "isReady") }
        didSet { didChangeValue(forKey: "isReady") }
    }

    var httpResponse: HTTPURLResponse?
    var autoDone = true
    var backgroundTaskIdentifier: String? { nil }
    var responseCacheData = Data()
    var backgroundTaskResponse: URLResponse?

    override init() {
        super.init()
    }

    func didStartTask() {}

    func checkResponse(_: HTTPURLResponse, responseBody _: Data?) throws -> Any {
        fatalError("You must override checkResponse.")
    }

    func completedOperation(with _: Any?, error _: NetworkError?) {
        fatalError("You must override completionHandler.")
    }
}

extension BaseNetworkOperation {
    override var isFinished: Bool {
        isDone
    }

    override var isAsynchronous: Bool {
        true
    }

    override var queuePriority: Operation.QueuePriority {
        get { priority }
        set { priority = newValue }
    }

    override var isReady: Bool {
        guard dependencies.count < 1 else { return false }
        return isReadyToRun
    }

    override func start() {
        if isCancelled {
            completedOperation(with: nil, error: .cancelled)
            isDone = true
            return
        }
        #if DEBUG
        printRequestInfo()
        #endif
        if let backgroundTaskIdentifier {
            runBackgroundTask(with: backgroundTaskIdentifier)
        } else {
            Task { await runTask() }
        }
    }

    private func runTask() async {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        do {
            didStartTask()
            let (responseBody, urlResponse) = try await session.data(for: request)
            try await finishSession(session, urlResponse: urlResponse, responseBody: responseBody)
        } catch {
            await finishSession(session, with: error)
        }
    }

    private func runBackgroundTask(with backgroundTaskIdentifier: String) {
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundTaskIdentifier)
        configuration.timeoutIntervalForResource = timeout
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        let processInfo = ProcessInfo()
        processInfo.performExpiringActivity(withReason: "Long Task") { [weak self] toBeSuspended in
            guard let self else { return }
            if toBeSuspended {
                Task { [weak self] in await self?.finishSession(session, with: NetworkError.cancelled) }
            } else {
                didStartTask()
                session.dataTask(with: request).resume()
            }
        }
    }

    private func finishSession(_ session: URLSession, urlResponse: URLResponse, responseBody: Data) async throws {
        guard !isCancelled else { throw NetworkError.cancelled }
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        self.httpResponse = httpResponse

        let result = try checkResponse(httpResponse, responseBody: responseBody)
        print("""
                ========= Start Response ========= \(Date().toString(by: "yyyy-MM-dd HH:mm:ss"))
                \(getResponseInfoString(responseBody, result, nil))
                =========  End  Response =========
                """)
        completedOperation(with: result, error: nil)
        if autoDone {
            isDone = true
        }
        session.finishTasksAndInvalidate()
    }

    private func finishSession(_ session: URLSession, with error: Error) async {
        session.finishTasksAndInvalidate()
        let networkError = NetworkError(error)
        completedOperation(with: nil, error: networkError)
        isDone = true
    }
}

extension BaseNetworkOperation: URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_: URLSession, task _: URLSessionTask,
                    willPerformHTTPRedirection _: HTTPURLResponse, newRequest _: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        completionHandler(nil)
    }

    func urlSession(
        _ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        backgroundTaskResponse = response
        return .allow
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseCacheData.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { [weak self] in
            guard let self else { return }
            if let error {
                await finishSession(session, with: error)
                return
            }
            guard let backgroundTaskResponse else {
                await finishSession(session, with: NetworkError.invalidResponse)
                return
            }
            do {
                try await finishSession(session, urlResponse: backgroundTaskResponse, responseBody: responseCacheData)
            } catch {
                await finishSession(session, with: error)
            }
        }
    }
}

// MARK: - For debug
extension BaseNetworkOperation {
    private func printRequestInfo() {
        let urlString = request.url?.absoluteString ?? ""
        let method = method
        let header = request.allHTTPHeaderFields?.prettyPrintedJSON ?? ""
        let body = if let requestBody = request.httpBody {
            if requestBody.count < 2000 {
                "\nBODY:\(requestBody.utf8String?.removingPercentEncoding ?? "")"
            } else {
                "\nThe request body size is too large to print log. size:\(requestBody.count)"
            }
        } else {
            ""
        }

        print("""
        ========= Start Request ========= \(Date().toString(by: "yyyy-MM-dd HH:mm:ss"))
        Request \(urlString)
        Method:\(method)
        HEADER:\(header)\(body)
        =========  End  Request  =========
        """)
    }

    private func getResponseInfoString(_ responseBody: Data?, _ response: Any?,
                                       _ networkError: NetworkError?) -> String {
        var result = ""
        let urlString = request.url?.absoluteString ?? ""
        result.append("Response \(urlString) Method:\(method)")
        if let httpResponse {
            result.append("\nHTTP Status code:\(httpResponse.statusCode)")
            //            result.append("HTTP Headers:\(httpResponse.allHeaderFields.prettyPrintedJSON ?? "")")
        }
        if let error = networkError {
            result.append("\nERROR:\(error)")
            if let responseBody {
                if let jsonBody = responseBody.prettyPrintedJSON {
                    result.append("\nBODY:\(jsonBody)")
                } else {
                    result.append("\nBODY:\(String(data: responseBody, encoding: .utf8) ?? "")")
                }
            }
        } else {
            if let json = response as? [String: Any] {
                result.append("\nBODY:\(json.prettyPrintedJSON ?? "")")
            } else if let string = response as? String {
                result.append("\nBODY:\(string)")
            }
        }
        return result
    }
}


