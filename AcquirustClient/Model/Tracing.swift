//
//  Tracing.swift
//  AcquirustClient
//
//  Created by George Nikolaev on 18.02.2024.
//

import Foundation
import Starscream

class Tracing: NSObject {

    // Web socket
    private var socket: WebSocket!

    static let shared = Tracing.init()
    static let helper = {
        let helper = AMR_ANSIEscapeHelper()
        helper.defaultStringColor = .white
        helper.font = NSFont(name: "JetBrains Mono", size: 15)
        return helper
    }
    
    var logs = NSMutableAttributedString()

    weak var delegate: TracingViewController? {
        didSet {
            delegate!.append(with: logs)
        }
    }

    override init() {
        super.init()
        
        let config = AppConfig.shared
        let endpoint = config.data.endpoint
        var request = URLRequest(
            endpoint: endpoint, path: ["system", "subscribe_on_traces"],
            method: "GET")
        request.basicAuth(
            username: config.data.username, password: config.data.password)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func updateConnection() {
        socket.forceDisconnect()
        socket.connect()
    }

}

func convert(input: String) -> NSAttributedString {
    return Tracing.helper().attributedString(withANSIEscapedString: input)
}

extension Tracing: WebSocketDelegate {
    func didReceive(
        event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient
    ) {
        switch event {
            case .text(let text):
                let attributed = convert(input: text)
                logs.append(attributed)

                if let delegate = delegate {
                    delegate.append(with: convert(input: text))
                }
            case .peerClosed:
                client.disconnect()
                if let delegate = delegate {
                    delegate.append(with: convert(input: "Connection lost!"))
                }
            default:
                return
        }
    }
}
