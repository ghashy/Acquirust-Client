//
//  EntriesModel.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

enum EntryType: Identifiable {
    case Commands, Accounts, Transactions, Logs
    var id: Self {
        return self
    }
}

struct Entry: Identifiable {
    let id: EntryType
    let name: String
    let icon_name: String
}

final class EntriesModel: ObservableObject {
    @Published var entries: [Entry]
    @Published var selectedEntry: EntryType?

    init() {
        entries = EntriesModel.defaultEntries
        selectedEntry = EntryType.Commands
    }

    static let defaultEntries: [Entry] = [
        (EntryType.Commands, "Commands", "square.and.pencil"),
        (EntryType.Accounts, "Accounts", "person.crop.circle"),
        (EntryType.Transactions, "Transactions", "creditcard.circle"),
        (EntryType.Logs, "Logs", "exclamationmark.bubble"),
    ]
    .map { Entry(id: $0.0, name: $0.1, icon_name: $0.2) }
}
