//
//  DevModeView.swift
//  SideStore
//
//  Created by naturecodevoid on 2/16/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI
import LocalConsole

struct DevModePrompt: View {
    @Binding var isShowingDevModePrompt: Bool
    @Binding var isShowingDevModeMenu: Bool
    
    @State var countdown = 0
    
    var button: some View {
        SwiftUI.Button(action: {
            UserDefaults.standard.isDevModeEnabled = true
            isShowingDevModePrompt = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                isShowingDevModeMenu = true
            }
        }) {
            Text(countdown <= 0 ? L10n.Action.enable + " " + L10n.DevModeView.title : L10n.DevModeView.read + " (\(countdown))")
                .foregroundColor(.red)
        }
        .disabled(countdown > 0)
    }
    
    var text: some View {
        if #available(iOS 15.0, *) {
            do {
                return Text(try AttributedString(markdown: L10n.DevModeView.prompt, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
            } catch {
                return Text(L10n.DevModeView.prompt)
            }
        } else {
            return Text(L10n.DevModeView.prompt)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    text
                        .foregroundColor(.primary)
                        .padding(.bottom)
                    
                    if #available(iOS 15.0, *) {
                        button.buttonStyle(.bordered)
                    } else {
                        button
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .navigationTitle(L10n.DevModeView.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SwiftUI.Button(action: { isShowingDevModePrompt = false }) {
                        Text(L10n.Action.close)
                    }
                }
            }
            .onAppear {
                countdown = 20
                tickCountdown()
            }
        }
    }
    
    func tickCountdown() {
        if countdown <= 0 { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            countdown -= 1
            tickCountdown()
        }
    }
}

struct DevModeMenu: View {
    @ObservedObject private var iO = Inject.observer
    
    @AppStorage("isConsoleEnabled")
    var isConsoleEnabled: Bool = false
    
    var body: some View {
        List {
            Section {
                Toggle(L10n.DevModeView.console, isOn: self.$isConsoleEnabled)
                    .onChange(of: self.isConsoleEnabled) { value in
                        LCManager.shared.isVisible = value
                    }
                
                NavigationLink(L10n.DevModeView.dataExplorer) {
                    FileExplorer(url: FileManager.default.altstoreSharedDirectory)
                        .navigationTitle(L10n.DevModeView.dataExplorer)
                }.foregroundColor(.red)
                
                NavigationLink(L10n.DevModeView.tmpExplorer) {
                    FileExplorer(url: FileManager.default.temporaryDirectory)
                        .navigationTitle(L10n.DevModeView.tmpExplorer)
                }.foregroundColor(.red)
                
                Toggle(L10n.DevModeView.skipResign, isOn: ResignAppOperation.skipResignBinding)
                    .foregroundColor(.red)
            } footer: {
                Text(L10n.DevModeView.skipResignInfo)
            }
            
            Section {
                NavigationLink(L10n.DevModeView.Minimuxer.stagingExplorer + " (Coming soon, needs minimuxer additions)") {
                    FileExplorer(url: FileManager.default.altstoreSharedDirectory)
                        .navigationTitle(L10n.DevModeView.Minimuxer.stagingExplorer)
                }.foregroundColor(.red).disabled(true)
                
                NavigationLink(L10n.DevModeView.Minimuxer.viewProfiles + " (Coming soon, needs minimuxer additions)") {
                    
                }.disabled(true)
                
                SwiftUI.Button(L10n.DevModeView.Minimuxer.dumpProfiles + " (Coming soon, needs minimuxer additions)", action: {
                    // TODO: dump profiles to Documents/ProfileDump/[current time]
                }).disabled(true)
            } header: {
                Text(L10n.DevModeView.minimuxer)
            }
        }
        .navigationTitle(L10n.DevModeView.title)
        .enableInjection()
    }
}

struct DevModeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                NavigationLink("DevModeMenu") {
                    DevModeMenu()
                }
            }
        }
    }
}
