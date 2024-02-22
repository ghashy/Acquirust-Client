//
//  Tracing.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 18.02.2024.
//

import Foundation

class Tracing: NSObject {

    // Singletone
    static let shared = Tracing.init()

    // State
    private var socketTask: URLSessionWebSocketTask!
    private var session: URLSession!
    private var logs = NSMutableAttributedString()
    private let helper = {
        let helper = AMR_ANSIEscapeHelper()
        helper.defaultStringColor = .white
        helper.font = NSFont(name: "JetBrains Mono", size: 15)
        return helper
    }

    // Delegate
    weak var delegate: TracingViewController? {
        didSet {
            delegate!.append(with: logs)
        }
    }

    override init() {
        super.init()
        session = URLSession(
            configuration: .default, delegate: self,
            delegateQueue: OperationQueue.main)
        updateConnection()
    }

    func updateConnection() {
        createSocketTask()
    }
}

extension Tracing {
    private func prepareRequest() -> URLRequest {
        let config = AppConfig.shared
        let endpoint = config.data.endpoint
        var request = URLRequest(
            endpoint: endpoint, path: ["system", "subscribe_on_traces"],
            method: "GET")
        request.basicAuth(
            username: config.data.username, password: config.data.password)
        request.timeoutInterval = 5
        return request
    }
    
    private func createSocketTask() {
        socketTask = session.webSocketTask(with: prepareRequest())
        socketTask.delegate = self
        socketTask.resume()
    }
    
    private func convert(input: String) -> NSAttributedString {
        return helper().attributedString(withANSIEscapedString: input)
    }
    
    private func update(input: String) {
        let attributed = convert(input: input)
        logs.append(attributed)
        if let delegate = delegate {
            delegate.append(with: attributed)
        }
    }
    
    private func receive() {
        socketTask?.receive(completionHandler: { [weak self] result in
            switch result {
                case .success(let message):
                    switch message {
                        case .string(let logs):
                            self?.update(input: logs)
                        default:
                            break
                    }
                case .failure(let error):
                    print("Failed to receive message over ws: \(error)")
                    self?.update(input: "\nDisconnected from server!\n\n")
                    return
            }
            self?.receive()
        })
    }
}

// MARK: Notifier: URLSessionWebSocketDelegate
extension Tracing: URLSessionWebSocketDelegate {
    func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol p: String?
    ) {
        print("Did open url socket session with protocol: \(String(describing: p))")
        update(input: "Connected to server!\n\n")
        receive()
    }
    func urlSession(
        _ session: URLSession, webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?
    ) {
        print("Did close url socket session with reason: \(String(describing: reason))")
    }
}

// MARK: URLSessionDelegate
extension Tracing: URLSessionDelegate {}
