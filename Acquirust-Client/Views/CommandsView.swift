//
//  CommandsView.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

struct CommandsView: View {
    var body: some View {
        List {
            CommandRowView(command_type: .AddAccount)
            CommandRowView(command_type: .DeleteAccount)
            CommandRowView(command_type: .OpenCredit)
            CommandRowView(command_type: .NewTransaction)
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
}

struct CommandRowView: View {
    @State var responseText: String = "Response"
    let command_type: CommandType
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                switch command_type {
                case .AddAccount: AddAccountView(
                        responseText: $responseText
                    )
                case .DeleteAccount: DeleteAccountView(
                        responseText: $responseText
                    )
                case .OpenCredit: OpenCreditView(responseText: $responseText)
                case .NewTransaction: NewTransactionView(
                        responseText: $responseText
                    )
                }
            }
            .padding()
            Spacer()
            Text(responseText)
                .foregroundStyle(.gray)
                .textSelection(.enabled)
            Spacer()
        }
    }
}

struct AddAccountView: View {
    @State var passwordInput: String = ""
    @EnvironmentObject var httpClient: HttpClient
    @Binding var responseText: String

    var body: some View {
        Text("Add account")
            .font(.title2)
        TextField("Password", text: $passwordInput)
            .frame(maxWidth: 250)
            .textFieldStyle(.squareBorder)
            .offset(CGSize(width: -9.0, height: -5.0))
        Button(action: {
            httpClient.addAccount(password: passwordInput) { response in
                responseText = response
            }
        }) {
            Text("Add")
        }
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct DeleteAccountView: View {
    @State var cardInput: String = ""
    @EnvironmentObject var httpClient: HttpClient
    @Binding var responseText: String

    var body: some View {
        Text("Delete account")
            .font(.title2)
        TextField("Card number", text: $cardInput)
            .frame(maxWidth: 250)
            .textFieldStyle(.squareBorder)
            .offset(CGSize(width: -9.0, height: -5.0))
        Button(action: {
            httpClient.deleteAccount(cardNumber: cardInput) { response in
                responseText = response
            }
        }) {
            Text("Delete")
        }
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct OpenCreditView: View {
    @State var cardInput: String = ""
    @State var amountInput: String = ""
    @EnvironmentObject var httpClient: HttpClient
    @Binding var responseText: String

    var body: some View {
        Text("Open credit")
            .font(.title2)
        HStack {
            TextField("Card number", text: $cardInput)
                .frame(maxWidth: 121)
                .textFieldStyle(.squareBorder)
                .offset(CGSize(width: -9.0, height: -5.0))
            TextField("Amount", text: $amountInput)
                .frame(maxWidth: 121)
                .textFieldStyle(.squareBorder)
                .offset(CGSize(width: -9.0, height: -5.0))
        }
        Button(action: {
            guard let amount = Int(amountInput) else {
                responseText = "Faild to parse amount as Int"
                return
            }
            httpClient
                .openCredit(cardNumber: cardInput,
                            amount: amount)
            { response in
                responseText = response
            }
        }) {
            Text("Open")
        }
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

struct NewTransactionView: View {
    @State var fromCardInput: String = ""
    @State var toCardInput: String = ""
    @State var amountInput: String = ""

    @EnvironmentObject var httpClient: HttpClient
    @Binding var responseText: String

    var body: some View {
        Text("New transaction")
            .font(.title2)
        HStack {
            TextField("From", text: $fromCardInput)
                .frame(maxWidth: 121)
                .textFieldStyle(.squareBorder)
                .offset(CGSize(width: -9.0, height: -5.0))
            TextField("To", text: $toCardInput)
                .frame(maxWidth: 121)
                .textFieldStyle(.squareBorder)
                .offset(CGSize(width: -9.0, height: -5.0))
        }
        TextField("Amount", text: $amountInput)
            .frame(maxWidth: 250)
            .textFieldStyle(.squareBorder)
            .offset(CGSize(width: -9.0, height: -5.0))
        Button(action: {
            guard let amount = Int(amountInput) else {
                responseText = "Failed to parse amount as Int"
                return
            }
            httpClient.newTransaction(
                fromCardNumber: fromCardInput,
                toCardNumber: toCardInput,
                amount: amount
            ) { response in
                responseText = response
            }
        }) {
            Text("Create")
        }
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    CommandsView()
}
