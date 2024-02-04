//
//  HttpClient.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 04.02.2024.
//

import Foundation

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
    ///   - completion: completion handler with response information
    func addAccount(_ password: String, closure: @escaping (String) -> Void) {
        // Prepare request with path
        var request = URLRequest(url: appConfig.data.endpoint
            .appendingPathComponent("system").appendingPathComponent("account"))

        // Setup method and format
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        // Auth
        request.basicAuth(
            username: appConfig.data.username,
            password: appConfig.data.password
        )

        // Prepare body
        let body: [String: Any] = [
            "password": password,
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
                bodyType: [String: Any].self
            ) { body in
                let cardNumber =
                    body["card_number"] as? String ?? "unknown"
                return "Card number: " + cardNumber
            }
            closure(response)
        }.resume()
    }
}

func messageFromJsonResponse<BodyType>(
    data: Data?,
    response: URLResponse?,
    error: Error?,
    successCode: Int,
    bodyType _: BodyType.Type,
    bodyHandler: (BodyType) -> String
) -> String {
    if let response = response as? HTTPURLResponse {
        if response.statusCode == successCode {
            guard let data = data,
                  let responseBody = try? JSONSerialization
                  .jsonObject(with: data) as? BodyType
            else {
                return "Failed to deserialize response body"
            }
            let message = bodyHandler(responseBody)
            return "Success. " + message
        } else {
            var responseString = "Error, code: " +
                String(response.statusCode)
            if let error = error {
                responseString.append(" " + error.localizedDescription)
            }
            return responseString
        }
    } else {
        let responseString = "No response. Error: " +
            (error?.localizedDescription ?? "unknown")
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
}
