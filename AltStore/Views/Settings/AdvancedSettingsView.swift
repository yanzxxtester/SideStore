//
//  AdvancedSettingsView.swift
//  SideStore
//
//  Created by naturecodevoid on 2/19/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI

private struct Server: Identifiable {
    var id: String { value }
    var display: String
    var value: String
}

struct AdvancedSettingsView: View {
    @ObservedObject private var iO = Inject.observer
    
    private let anisetteServers = [
        Server(display: "SideStore", value: "http://ani.sidestore.io"),
        Server(display: "Macley (US)", value: "http://us1.sternserv.tech"),
        Server(display: "Macley (DE)", value: "http://de1.sternserv.tech"),
        Server(display: "DrPudding", value: "https://sign.rheaa.xyz"),
        Server(display: "jkcoxson (AltServer)", value: "http://jkcoxson.com:2095"),
        Server(display: "jkcoxson (Provision)", value: "http://jkcoxson.com:2052"),
        Server(display: "Sideloadly", value: "https://sideloadly.io/anisette/irGb3Quww8zrhgqnzmrx"),
        Server(display: "Nick", value: "http://45.33.29.114"),
        Server(display: "Jawshoeadan", value: "https://anisette.jawshoeadan.me"),
        Server(display: "crystall1nedev", value: "https://anisette.crystall1ne.software/"),
    ]
    
    @AppStorage("textServer")
    var usePreferred: Bool = true
    
    @AppStorage("textInputAnisetteURL")
    var anisetteURL: String = ""
    
    @AppStorage("customAnisetteURL")
    var selectedAnisetteServer: String = ""
    
    var body: some View {
        List {
            Section {
                Picker(L10n.AdvancedSettingsView.anisette, selection: $selectedAnisetteServer) {
                    ForEach(anisetteServers) { server in
                        Text(server.display)
                    }
                }
            }
            
            Section {
                Toggle(L10n.AdvancedSettingsView.DangerZone.usePreferred, isOn: $usePreferred)
                
                TextField(L10n.AdvancedSettingsView.DangerZone.anisetteURL, text: $anisetteURL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
            } header: {
                Text(L10n.AdvancedSettingsView.dangerZone)
            } footer: {
                Text(L10n.AdvancedSettingsView.dangerZoneInfo)
            }
        }
        .navigationTitle(L10n.AdvancedSettingsView.title)
        .enableInjection()
    }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedSettingsView()
    }
}
