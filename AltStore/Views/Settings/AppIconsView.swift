//
//  AppIconsView.swift
//  SideStore
//
//  Created by naturecodevoid on 2/14/23.
//  Copyright © 2023 SideStore. All rights reserved.
//

import SwiftUI
import SFSafeSymbols

struct Icon: Identifiable {
    var id: String { assetName }
    var displayName: String
    let assetName: String
}

struct SpecialIcon {
    let assetName: String
    let suffix: String?
    let forceIndex: Int?
}

struct AppIconsView: View {
    private let specialIcons = [
        SpecialIcon(assetName: "Neon", suffix: "(Stable)", forceIndex: 0),
        SpecialIcon(assetName: "Starburst", suffix: "(Beta)", forceIndex: 1),
        SpecialIcon(assetName: "Steel", suffix: "(Nightly)", forceIndex: 2),
    ]
    private var icons: [Icon] = []
    
    @State private var selectedIcon: String? = "" // this is just so the list row background changes when selecting a value, I couldn't get it to keep the selected icon name (for some reason it was always "", even when I set it to the selected icon asset name)
    @State private var selectedIconAssetName: String // FIXME: use selectedIcon instead
    
    init() {
        let bundleIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as! [String: Any]
        
        let primaryIcon = bundleIcons["CFBundlePrimaryIcon"] as! [String: Any]
        let primaryIconName = primaryIcon["CFBundleIconName"] as! String
        icons.append(Icon(displayName: primaryIconName, assetName: primaryIconName)) // ensure primary icon is first
        
        for (key, _) in bundleIcons["CFBundleAlternateIcons"] as! [String: Any] {
            icons.append(Icon(displayName: key, assetName: key))
        }
        
        // sort alphabetically
        icons.sort { $0.assetName < $1.assetName }
        
        for specialIcon in specialIcons {
            guard let icon = icons.enumerated().first(where: { $0.element.assetName == specialIcon.assetName }) else { continue }
            
            if let suffix = specialIcon.suffix {
                icons[icon.offset].displayName += " " + suffix
            }
            
            if let forceIndex = specialIcon.forceIndex {
                let e = icons.remove(at: icon.offset)
                icons.insert(e, at: forceIndex)
            }
        }
        
        if let alternateIconName = UIApplication.shared.alternateIconName {
            selectedIconAssetName = icons.first { $0.assetName == alternateIconName }?.assetName ?? icons[0].assetName
        } else {
            selectedIconAssetName = icons[0].assetName
        }
    }
    
    var body: some View {
        List(icons, selection: $selectedIcon) { icon in
            // FIXME: Button gives errors for some reason
            SwiftUI.Button(action: {
                selectedIconAssetName = icon.assetName
                // Pass nil for original icon
                UIApplication.shared.setAlternateIconName(icon.assetName == icons[0].assetName ? nil : icon.assetName, completionHandler: { error in
                    if let error = error {
                        print("error when setting alternate app icon to \(icon.assetName): \(error.localizedDescription)")
                    } else {
                        print("successfully changed app icon to \(icon.assetName)")
                    }
                })
            }) {
                HStack(spacing: 20) {
                    // if we don't have an additional image asset for each icon, it will have low resolution
                    Image(uiImage: UIImage(named: icon.assetName + "-image") ?? UIImage())
                        .resizable()
                        .renderingMode(.original)
                        .cornerRadius(12.6) // https://stackoverflow.com/a/10239376
                        .frame(width: 72, height: 72)
                    Text(icon.displayName)
                    Spacer()
                    if selectedIconAssetName == icon.assetName {
                        Image(systemSymbol: .checkmark)
                            .foregroundColor(Color.blue)
                    }
                }
            }.foregroundColor(Color.white)
        }
        .navigationTitle(L10n.AppIconsView.title)
    }
}

struct AppIconsView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconsView()
    }
}
