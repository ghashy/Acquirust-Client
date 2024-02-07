//
//  HttpClient.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 04.02.2024.
//

import Foundation

enum RequestType {
    case AddAccount, DeleteAccount, OpenCredit, NewTransaction
}

enum HttpClientError: Error {
    case simple(String)
}

class HttpClient: ObservableObject {
    let appConfig: AppConfig
    let session: URLSession

    init(session: URLSession = .shared, appConfig: AppConfig) {
        self.appConfig = appConfig
        self.session = session
    }
}

extension HttpClient {
    /// Perform `AddAccount` request.
    /// - Parameters:
    ///   - password: cashbox password.
    ///   - handler: completion handler with response information
    func addAccount(password: String, handler: @escaping (String) -> Void) {
        var request = URLRequest(
            endpoint: appConfig.data.endpoint,
            path: ["system", "account"],
            method: "POST"
        )
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Prepare body
        let body: [String: String] = [
            "password": password,
        ]
        guard let httpBody = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            handler("Failed to serialize request body")
            return
        }
        request.httpBody = httpBody

        // Run task
        session.dataTask(with: request) { data, response, error in
            let response = messageFromJsonResponse(
                data: data,
                response: response,
                error: error,
                successCode: 200,
                bodyType: [String: String].self
            ) { body in
                let cardNumber =
                    body["card_number"] ?? "unknown"
                return "Card number: " + cardNumber
            }
            handler(response)
        }.resume()
    }

    /// Perform `DeleteAccount` request.
    /// - Parameters:
    ///   - cardNumber: user card number.
    ///   - handler: completion handler with response information
    func deleteAccount(cardNumber: String, handler: @escaping (String) -> Void)
    {
        var request = URLRequest(
            endpoint: appConfig.data.endpoint,
            path: ["system", "account"],
            method: "DELETE"
        )
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Prepare body
        let body: [String: Any] = [
            "card_number": cardNumber,
        ]
        guard let httpBody = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            handler("Failed to serialize request body")
            return
        }
        request.httpBody = httpBody

        // Run task
        session.dataTask(with: request) { data, response, error in
            let response = messageFromJsonResponse(
                data: data,
                response: response,
                error: error,
                successCode: 200,
                bodyType: Int.self
            )
            handler(response)
        }.resume()
    }

    /// Perform `OpenCredit` request.
    /// - Parameters:
    ///   - cardNumber: user card number.
    ///   - amount: money amount in Kopecks to send into given card.
    ///   - closure: completion handler with response information
    func openCredit(
        cardNumber: String,
        amount: Int,
        closure: @escaping (String) -> Void
    ) {
        var request = URLRequest(
            endpoint: appConfig.data.endpoint,
            path: ["system", "credit"],
            method: "POST"
        )
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Prepare body
        let body: [String: Any] = [
            "card_number": cardNumber,
            "amount": amount,
        ]
        guard let httpBody = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            closure("Failed to serialize request body")
            return
        }
        request.httpBody = httpBody

        // Run task
        session.dataTask(with: request) { data, response, error in
            let response = messageFromJsonResponse(
                data: data,
                response: response,
                error: error,
                successCode: 200,
                bodyType: Int.self
            )
            closure(response)
        }.resume()
    }

    /// Perform `NewTransaction` request.
    /// - Parameters:
    ///   - cardNumber: user card number.
    ///   - amount: money amount in Kopecks to send into given card.
    ///   - handler: completion handler with response information
    func newTransaction(
        fromCardNumber: String,
        toCardNumber: String,
        amount: Int,
        handler: @escaping (String) -> Void
    ) {
        var request = URLRequest(
            endpoint: appConfig.data.endpoint,
            path: ["system", "transaction"],
            method: "POST"
        )
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Prepare body
        let body: [String: Any] = [
            "from": fromCardNumber,
            "to": toCardNumber,
            "amount": amount,
        ]
        guard let httpBody = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        ) else {
            handler("Failed to serialize request body")
            return
        }
        request.httpBody = httpBody

        // Run task
        session.dataTask(with: request) { data, response, error in
            let response = messageFromJsonResponse(
                data: data,
                response: response,
                error: error,
                successCode: 200,
                bodyType: Int.self
            )
            handler(response)
        }.resume()
    }

    /// Perform `ListAccounts` request.
    /// - Parameters:
    ///   - handler: completion handler
    func listAccounts(handler: @escaping (Result< [AccountInfo], HttpClientError >?) -> Void) {
        // Prepare request with path
        var request = URLRequest(url: appConfig.data.endpoint
            .appendingPathComponent("system")
            .appendingPathComponent("list_accounts"))

        // Setup method and format
        request.httpMethod = "GET"

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Run task
        session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse else {
                handler(.failure(HttpClientError.simple("No response")))
                return
            }

            if response.statusCode == 200 {
                guard let data = data else {
                    handler(.failure(HttpClientError
                            .simple("No data in response")))
                    return
                }
                let response = Result { try JSONDecoder().decode(
                    ListAccountsResponse.self,
                    from: data
                ) }.map { request in
                    request.accounts
                }.mapError { error in
                    HttpClientError.simple("JSONDecoder error: \(error.localizedDescription)")
                }
                handler(response)
            } else {
                var responseString = "Error, code: " +
                    String(response.statusCode)
                if let error = error {
                    responseString.append(" " + error.localizedDescription)
                }
                if let data = data, let response = String(
                    data: data,
                    encoding: .utf8
                ), !response.isEmpty {
                    responseString += " Response: " + response
                }
                handler(.failure(HttpClientError.simple(responseString)))
            }
        }.resume()
    }
}

func messageFromJsonResponse<BodyType>(
    data: Data?,
    response: URLResponse?,
    error: Error?,
    successCode: Int,
    bodyType _: BodyType.Type,
    stringify: ((BodyType) -> String)? = nil
) -> String {
    // Is response not nil
    guard let response = response as? HTTPURLResponse else {
        let responseString = "No response. Error: " +
            (error?.localizedDescription ?? "unknown")
        return responseString
    }

    // Is response success
    if response.statusCode == successCode {
        // Should we deserialize or just check status code
        if let stringify = stringify {
            // Try to deserialize
            guard let data = data,
                  let responseBody = try? JSONSerialization
                  .jsonObject(with: data) as? BodyType
            else {
                return "Failed to deserialize response body"
            }
            // Stringify
            let message = stringify(responseBody)
            return "Success. \(message)"
        } else {
            return "Success"
        }
    } else {
        var responseString = "Error, code: \(response.statusCode)"
        if let error = error {
            responseString.append(" " + error.localizedDescription)
        }
        if let data = data, let response = String(
            data: data,
            encoding: .utf8
        ), !response.isEmpty {
            responseString += " Response: \(response)"
        }
        return responseString
    }
}

extension URLRequest {
    mutating func basicAuth(username: String, password: String) {
        let credentials = username + ":" + password
        guard let credentialsBase64 = credentials.data(using: .utf8)?
            .base64EncodedString()
        else {
            fatalError("Failed to encode string into base64")
        }
        setValue(
            "Basic " + credentialsBase64,
            forHTTPHeaderField: "Authorization"
        )
    }

    init(endpoint: URL, path: [String], method: String) {
        var endpoint = endpoint

        // Prepare request with path
        for entry in path {
            endpoint.append(component: entry)
        }

        self.init(url: endpoint)

        // Setup method and format
        httpMethod = method
    }
}
