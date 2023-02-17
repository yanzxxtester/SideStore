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
    private let artists = [
        "Chris (LitRitt)": ["Neon", "Starburst", "Steel", "Storm"],
        "naturecodevoid": ["Honeydew", "Midnight", "Sky"]
    ]
    
    private var icons: [Icon] = []
    private var primaryIcon: Icon
    
    @State private var selectedIcon: String? = "" // this is just so the list row background changes when selecting a value, I couldn't get it to keep the selected icon name (for some reason it was always "", even when I set it to the selected icon asset name)
    @State private var selectedIconAssetName: String // FIXME: use selectedIcon instead
    
    init() {
        let bundleIcons = Bundle.main.object(forInfoDictionaryKey: "CFBundleIcons") as! [String: Any]
        
        let primaryIconData = bundleIcons["CFBundlePrimaryIcon"] as! [String: Any]
        let primaryIconName = primaryIconData["CFBundleIconName"] as! String
        primaryIcon = Icon(displayName: primaryIconName, assetName: primaryIconName)
        icons.append(primaryIcon)
        
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
            selectedIconAssetName = icons.first { $0.assetName == alternateIconName }?.assetName ?? primaryIcon.assetName
        } else {
            selectedIconAssetName = primaryIcon.assetName
        }
    }
    
    var body: some View {
        List(icons, selection: $selectedIcon) { icon in
            SwiftUI.Button(action: {
                selectedIconAssetName = icon.assetName
                // Pass nil for primary icon
                UIApplication.shared.setAlternateIconName(icon.assetName == primaryIcon.assetName ? nil : icon.assetName, completionHandler: { error in
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
                    VStack(alignment: .leading) {
                        Text(icon.displayName)
                        if let artist = artists.first(where: { $0.value.contains(icon.assetName) }) {
                            Text("By " + artist.key)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    if selectedIconAssetName == icon.assetName {
                        Image(systemSymbol: .checkmark)
                            .foregroundColor(Color.blue)
                    }
                }
            }.foregroundColor(.primary)
        }
        .navigationTitle(L10n.AppIconsView.title)
    }
}

struct AppIconsView_Previews: PreviewProvider {
    static var previews: some View {
        AppIconsView()
    }
}
