//
//  AccountsView.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 06.02.2024.
//

import SwiftUI

struct AccountsView: View {
    @State private var accountsList: [AccountInfo] = []
    @State private var accountsListError: HttpClientError? = nil
    @EnvironmentObject var httpClient: HttpClient

    init(accountsList: [AccountInfo]) {
        self.accountsList = accountsList
    }
    
    init() {}

    func update() {
        httpClient.listAccounts { list in
            guard let list = list else {
                print("is empty")
                return
            }
            switch list {
                case let .success(list): accountsList = list
                // TODO: show somehow error in gui, not just print
                case let .failure(error): accountsListError = error; print(error)
            }
        }
    }

    var body: some View {
        List {
            ForEach(accountsList, id: \.self.cardNumber) { account in
                VStack(alignment: .leading) {
                    Text("Account")
                        .font(.headline)
                    Text("Card number:")
                        .font(.subheadline)
                    Text(account.cardNumber.uuidString)
                        .font(.subheadline.monospaced())
                    Text("Transactions count:")
                        .font(.subheadline)
                    Text(account.transactions.count.description)
                        .font(.subheadline.monospaced())
                    Text("Balance")
                        .font(.subheadline)
                    Text(account.balance.description)
                        .font(.subheadline.monospaced())
                }
                .textSelection(.enabled)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onAppear {
            update()
        }
    }
}

func initializeListAccountsRequest() -> ListAccountsResponse {
    var array = [AccountInfo]()
    for _ in 0...10 {
        let sender = Account(cardNumber: UUID(), isExisting: true)
        let recipient = Account(cardNumber: UUID(), isExisting: true)
        let transaction = Transaction(
            sender: sender,
            recipient: recipient,
            amount: 10,
            datetime: Date()
        )
        let account_info = AccountInfo(
            cardNumber: sender.cardNumber,
            balance: 100,
            transactions: [transaction]
        )
        array.append(account_info)
    }
    return ListAccountsResponse(accounts: array)
}

 #Preview {
    AccountsView(
        accountsList: initializeListAccountsRequest().accounts
    )
     .environmentObject(HttpClient(appConfig: AppConfig()))
 }
