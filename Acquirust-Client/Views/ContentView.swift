//
//  ContentView.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var entriesModel = EntriesModel()
    @State private var settingsVisibility: Bool = false

    var body: some View {
        NavigationView {
            List(selection: $entriesModel.selectedEntry) {
                ForEach(entriesModel.entries, id: \.id) { item in
                    NavigationLink {
                        switch entriesModel.selectedEntry {
                        case .Commands: CommandsView()
                        default: Text("Hello")
                        }
                    } label: {
                        Label(item.name, systemImage: item.icon_name)
                    }
                }
            }
            .listStyle(.sidebar)
            .frame(
                minWidth: 148,
                idealWidth: 160,
                maxWidth: 192,
                maxHeight: .infinity
            )
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigation) {
                Button {
                    toggleSidebar()
                } label: {
                    Image(systemName: "sidebar.left")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    settingsVisibility.toggle()
                }) {
                    Image(systemName: "gear")
                }
            }

        }).sheet(isPresented: $settingsVisibility, content: {
            SettingsView(settingsVisible: $settingsVisibility)
        })
    }
}

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(
        #selector(NSSplitViewController.toggleSidebar(_:)),
        with: nil
    )
}

#Preview {
    ContentView()
}
