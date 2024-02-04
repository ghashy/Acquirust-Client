//
//  JsonHelpers.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 05.02.2024.
//

import Foundation

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(
                with: data,
                options: []
            ) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func readJson() {
    // Get url for file
    guard let fileUrl = Bundle.main.url(
        forResource: "Data",
        withExtension: "json"
    ) else {
        print("File could not be located at the given url")
        return
    }

    do {
        // Get data from file
        let data = try Data(contentsOf: fileUrl)

        // Decode data to a Dictionary<String, Any> object
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: []
        ) as? [String: Any] else {
            print("Could not cast JSON content as a Dictionary<String, Any>")
            return
        }

        // Print result
        print(dictionary)
    } catch {
        // Print error if something went wrong
        print("Error: \(error)")
    }
}
