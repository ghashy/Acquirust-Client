//
//  Acquirust_ClientApp.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

@main
struct Acquirust_ClientApp: App {
    @StateObject private var settings: AppConfig
    @StateObject private var httpClient: HttpClient

    init() {
        let config = AppConfig()
        _settings = StateObject(wrappedValue: config)
        _httpClient = StateObject(wrappedValue: HttpClient(appConfig: config))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(httpClient)
        }
    }
}
