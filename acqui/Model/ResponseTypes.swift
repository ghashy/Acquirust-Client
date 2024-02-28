//
//  RequestTypes.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 04.02.2024.
//

import Foundation

struct Account: Codable {
    let cardNumber: String
    let isExisting: Bool

    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
        case isExisting = "is_existing"
    }
}

struct Transaction: Codable {
    let sender: Account
    let recipient: Account
    let amount: Int64
    let datetime: Date

    enum CodingKeys: String, CodingKey {
        case sender
        case recipient
        case amount
        case datetime
    }

    init(sender: Account, recipient: Account, amount: Int64, datetime: Date) {
        self.sender = sender
        self.recipient = recipient
        self.amount = amount
        self.datetime = datetime
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sender = try container.decode(Account.self, forKey: .sender)
        recipient = try container.decode(Account.self, forKey: .recipient)
        amount = try container.decode(Int64.self, forKey: .amount)

        let dateString = try container.decode(String.self, forKey: .datetime)
        let dateFormatter = ISO8601DateFormatter()
        if let date = dateFormatter.date(from: dateString) {
            datetime = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .datetime,
                in: container,
                debugDescription: "Invalid date format"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sender, forKey: .sender)
        try container.encode(recipient, forKey: .recipient)
        try container.encode(amount, forKey: .amount)

        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: datetime)
        try container.encode(dateString, forKey: .datetime)
    }
}

struct AccountInfo: Codable {
    let cardNumber: String
    let balance: Int64
    let transactions: [Transaction]
    let exists: Bool
    let tokens: [String]

    enum CodingKeys: String, CodingKey {
        case cardNumber = "card_number"
        case balance, transactions, exists, tokens
    }
    
    func tokensAsString() -> String {
        if tokens.isEmpty {
            return "No tokens"
        } else if tokens.count == 1 {
            return "Token: " + tokens.joined(separator: ", ")
        } else {
            return "Tokens: " + tokens.joined(separator: ", ")
        }
    }
}

struct ListAccountsResponse: Codable {
    let accounts: [AccountInfo]
}
