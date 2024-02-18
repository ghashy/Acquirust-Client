//
//  AppConfig.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import Foundation

private let configDir: String = ".config/acquirust-client"
private let configName: String = "config.json"
private let manager: FileManager = .init()

struct AppConfigData: Codable {
    var username: String
    var endpoint: URL
    var password: String
}

class AppConfig: ObservableObject {
    @Published var data: AppConfigData

    init(endpoint: URL, password: String, username: String) {
        let data = AppConfigData(
            username: username,
            endpoint: endpoint,
            password: password
        )
        self.data = data
    }

    init() {
        guard let homeDir = ProcessInfo.processInfo.environment["HOME"] else {
            fatalError("HOME env variable is not set!")
        }
        let dirPath = homeDir + "/" + configDir
        let configPath = dirPath + "/" + configName
        let config: AppConfigData
        if manager.fileExists(atPath: configPath) {
            if let configData = manager.contents(atPath: configPath) {
                do {
                    config = try JSONDecoder().decode(
                        AppConfigData.self,
                        from: configData
                    )
                } catch {
                    print("Failed to decode config: \(error)")
                    config = writeDefault(configPath)
                }
            } else {
                config = writeDefault(configPath)
            }
        } else {
            do {
                try manager.createDirectory(
                    atPath: configDir,
                    withIntermediateDirectories: true
                )
            } catch {
                fatalError("Failed to create config directory at \(configDir)")
            }
            config = writeDefault(configPath)
        }
        data = config
    }

    func save() {
        guard let homeDir = ProcessInfo.processInfo.environment["HOME"] else {
            fatalError("HOME env variable is not set!")
        }
        let path: String = homeDir + "/" + configDir + "/" + configName
        write(path, config: data)
    }
}

private func writeDefault(_ path: String) -> AppConfigData {
    let config = AppConfigData(
        username: "username",
        endpoint: URL(fileURLWithPath: NSHomeDirectory()),
        password: ""
    )
    write(path, config: config)
    return config
}

private func write(_ path: String, config: AppConfigData) {
    do {
        let data = try JSONEncoder().encode(config)
        guard case true = manager.createFile(atPath: path, contents: data)
        else {
            fatalError("Failed to write default config file")
        }
    } catch {
        fatalError(error.localizedDescription)
    }
}
