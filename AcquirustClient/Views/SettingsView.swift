//
//  SettingsView.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appConfig: AppConfig
    @State private var endpointField: String = ""
    @State private var usernameField: String = ""
    @State private var cashBoxPasswordField: String = ""
    @State private var badInput: Bool = false

    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Endpoint")
                    .font(.title3)
                TextField(text: $endpointField) {
                    Text("url address")
                }
            }
            .padding(.horizontal)
            .padding(.top)
            VStack(alignment: .leading) {
                Text("Username")
                    .font(.title3)
                TextField(text: $usernameField) {
                    Text("cashbox username")
                }
            }
            .padding(.horizontal)
            VStack(alignment: .leading) {
                Text("Password")
                    .font(.title3)
                TextField(text: $cashBoxPasswordField) {
                    Text("cashbox secret")
                }
            }
            .padding(.horizontal)
            Button(action: {
                guard let url = URL(string: endpointField) else {
                    badInput = true
                    return
                }
                appConfig.data.password = cashBoxPasswordField
                appConfig.data.endpoint = url
                appConfig.data.username = usernameField
                appConfig.save()
                (NSApp.mainWindow!.windowController as! WindowController).dismissSettings(self)
            }) {
                Text("Submit")
            }
            .padding()

            if badInput {
                Text("Bad url").foregroundStyle(.red)
            }
        }
        .textSelection(.enabled)
        .padding()
        .frame(
            minWidth: 250,
            maxWidth: 250,
            minHeight: 230,
            maxHeight: 230
        )
        .onDisappear {
            badInput = false
        }
        .onAppear {
            endpointField = appConfig.data.endpoint.absoluteString
            cashBoxPasswordField = appConfig.data.password
            usernameField = appConfig.data.username
        }
        .onExitCommand {
            (NSApp.mainWindow!.windowController as! WindowController).dismissSettings(self)
        }
    }
}

struct KeyEventHandling: NSViewRepresentable {
    class KeyView: NSView {
        override var acceptsFirstResponder: Bool { true }
        override func keyDown(with event: NSEvent) {
            print(">> key \(event.charactersIgnoringModifiers ?? "")")
        }
    }

    func makeNSView(context _: Context) -> NSView {
        let view = KeyView()
        DispatchQueue.main.async {  // wait till next event cycle
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

struct TestKeyboardEventHandling: View {
    var body: some View {
        Text("Hello, World!")
            .background(KeyEventHandling())
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppConfig())
}
