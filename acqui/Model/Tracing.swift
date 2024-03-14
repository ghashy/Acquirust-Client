//
//  Tracing.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 18.02.2024.
//

import Foundation
import Starscream

class Tracing: NSObject {
    // Singletone
    static let shared = Tracing.init()

    // State
    private var socket: WebSocket?
    private var isConnected = false
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
        socket = WebSocket(request: prepareRequest())
        socket?.delegate = self
        socket?.connect()
    }

    func updateConnection() {
        socket?.disconnect()
        socket = WebSocket(request: prepareRequest())
        socket?.delegate = self
        socket?.connect()
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
}

// MARK: Tracing: WebSocketDelegate
extension Tracing: WebSocketDelegate {
    func didReceive(
        event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient
    ) {
        switch event {
            case .connected(let m):
                print("Tracing WS connected, message: \(m)")
                isConnected = true
            case .disconnected(let reason, let code):
                print("Tracing WS disconnected: \(reason), \(code)")
                isConnected = false
            case .text(let logs):
                self.update(input: logs)
            case .error(let error):
                print("Tracing WS error: \(String(describing: error))")
                isConnected = false
            case .cancelled:
                print("Tracing WS cancelled")
                isConnected = false
            case .peerClosed:
                print("Tracing WS perr closed")
            default:
                print("Tracing WS event: \(event)")
        }
    }
}
