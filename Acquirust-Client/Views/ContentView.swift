//
//  ContentView.swift
//  Acquirust-Client
//
//  Created by George Nikolaev on 03.02.2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = EntriesModel()
    @State private var sideBarVisibility: NavigationSplitViewVisibility =
        .doubleColumn
    @State private var settingsVisibility: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(viewModel.entries,
                 selection: $viewModel.selected_entry)
            { item in
                HStack {
                    Image(systemName: item.icon_name)
                        .foregroundStyle(.blue)
                    Text(item.name)
                }
            }
            .listStyle(.sidebar)
            HStack {
                Text("Status:")
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundStyle(.green)
                Spacer()
            }
            .padding()
        } detail: {
            switch viewModel.selected_entry {
            case .Commands: CommandsView()
            default: Text("Hello")
            }
        }
        .toolbar(content: {
            Button(action: {
                settingsVisibility.toggle()
            }) {
                Image(systemName: "gear")
            }
        }).sheet(isPresented: $settingsVisibility, content: {
            SettingsView(settingsVisible: $settingsVisibility)
        })
    }
}

#Preview {
    ContentView()
}
